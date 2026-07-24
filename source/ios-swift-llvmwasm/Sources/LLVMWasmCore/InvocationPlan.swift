//
//  InvocationPlan.swift
//  LLVMWasmCore
//
//  A pure-Swift model of the WASI phase-split contract required to drive a *no-fork/exec* Wasm
//  compiler. Under WASI the `clang` driver cannot spawn `cc1` or `wasm-ld` as child processes, so a
//  host must run each compilation phase as its own engine invocation. This planner encodes that
//  contract — the ordered phases, the `argv[0]` multicall selection, and the two WASI I/O
//  workarounds — so it can be produced and asserted on any platform (Windows MSVC included) without
//  the 72 MB module present. Pure `Foundation`.
//

import Foundation

/// Source language of a compile request (selects `clang` vs `clang++` and the exceptions caveat).
public enum SourceLanguage: Sendable {
    case c
    case cpp
}

/// What the host is asking the toolchain to produce.
public struct CompileRequest: Sendable {
    /// Guest paths of the input source files.
    public var sources: [String]
    public var language: SourceLanguage
    /// Guest path of the final artifact (e.g. `/work/a.out.wasm`).
    public var output: String
    /// Target triple to cross-compile to.
    public var target: String
    /// Guest path of the extracted WASI sysroot `usr` directory.
    public var sysroot: String
    /// Optimization flag (e.g. `-O2`, `-Oz`).
    public var optimization: String
    public var extraCompileFlags: [String]
    public var extraLinkFlags: [String]

    public init(
        sources: [String],
        language: SourceLanguage,
        output: String,
        target: String = "wasm32-wasip1",
        sysroot: String,
        optimization: String = "-O2",
        extraCompileFlags: [String] = [],
        extraLinkFlags: [String] = []
    ) {
        self.sources = sources
        self.language = language
        self.output = output
        self.target = target
        self.sysroot = sysroot
        self.optimization = optimization
        self.extraCompileFlags = extraCompileFlags
        self.extraLinkFlags = extraLinkFlags
    }
}

/// A single Wasm-engine invocation: one tool personality, its guest args, and the host-side I/O
/// handling that works around WASI's limitations.
public struct EnginePhase: Equatable, Sendable {
    /// Which multicall personality to select via `argv[0]`.
    public let tool: Multicall
    /// The value the host must present as `argv[0]`.
    public var argv0: String { tool.argv0 }
    /// Guest arguments (after `argv[0]`).
    public let args: [String]
    /// Host directories that must be `--dir` / `--mapdir` preopened into the guest.
    public let preopens: [String]
    /// WASI can't seek-write, so the phase emits to stdout (`-o -`); the host captures stdout into
    /// this host file. `nil` means the phase writes no primary artifact via stdout.
    public let captureStdoutToHostFile: String?
    /// Human description of the phase.
    public let purpose: String
}

/// An ordered set of engine phases plus the notes a host runner needs.
public struct InvocationPlan: Equatable, Sendable {
    public let phases: [EnginePhase]
    /// Advisories the planner attached (e.g. the C++ no-exceptions caveat).
    public let advisories: [String]
}

/// Turns a `CompileRequest` into an `InvocationPlan` under the WASI phase-split contract.
///
/// The canonical shape is: one compile phase per source (`clang`/`clang++` → object), then one
/// link phase (`wasm-ld` → module). At runtime a host may instead capture `clang -###` to obtain
/// the exact `cc1`/`wasm-ld` argv; this planner encodes the *shape and the I/O rewrites* that any
/// such expansion must obey.
public struct InvocationPlanner: Sendable {

    /// Host directory mapped in as the guest work dir; also the rewrite target for `/tmp` paths,
    /// which WASI preopens do not cover by default.
    public let workDir: String

    public init(workDir: String = "/work") {
        self.workDir = workDir
    }

    /// Rewrite a guest path so it lives under the preopened work dir (WASI has no ambient `/tmp`).
    public func rewriteToWorkDir(_ path: String) -> String {
        guard path.hasPrefix("/tmp/") else { return path }
        return workDir + "/" + String(path.dropFirst("/tmp/".count))
    }

    public func plan(_ request: CompileRequest) -> InvocationPlan {
        let compiler: Multicall = request.language == .cpp ? .clangxx : .clang
        var advisories: [String] = []

        var compileFlags = [
            "--target=\(request.target)",
            request.optimization,
            "--sysroot=\(request.sysroot)",
        ]
        if request.language == .cpp {
            // The bundled libc++abi is a no-exceptions WASI build; C++ must disable EH/RTTI.
            compileFlags += ["-fno-exceptions", "-fno-rtti"]
            advisories.append(
                "C++ uses the bundled no-exceptions libc++abi: -fno-exceptions -fno-rtti are "
                + "required or wasm-ld will report undefined __cxa_throw / __cxa_allocate_exception.")
        }
        compileFlags += request.extraCompileFlags

        var phases: [EnginePhase] = []
        var objects: [String] = []

        for source in request.sources {
            let object = rewriteToWorkDir("/tmp/" + objectName(for: source))
            objects.append(object)
            phases.append(
                EnginePhase(
                    tool: compiler,
                    args: compileFlags + ["-c", rewriteToWorkDir(source), "-o", "-"],
                    preopens: uniquePreopens([workDir, request.sysroot, parentDir(source)]),
                    captureStdoutToHostFile: object,
                    purpose: "Compile \(source) → \(object) (emit to stdout; WASI can't seek-write)."
                )
            )
        }

        let linkFlags = [
            "-L\(request.sysroot)/lib/\(request.target)",
            "--max-memory=4294967296",
            "-z", "stack-size=8388608",
            "--stack-first",
        ] + request.extraLinkFlags

        phases.append(
            EnginePhase(
                tool: .wasmLD,
                args: objects + linkFlags + ["-o", "-"],
                preopens: uniquePreopens([workDir, request.sysroot]),
                captureStdoutToHostFile: request.output,
                purpose: "Link \(objects.joined(separator: ", ")) → \(request.output)."
            )
        )

        advisories.append(
            "Each phase is a separate engine invocation: the WASI clang driver cannot fork/exec "
            + "cc1 or wasm-ld.")
        return InvocationPlan(phases: phases, advisories: advisories)
    }

    // MARK: Helpers

    private func objectName(for source: String) -> String {
        let base = source.split(separator: "/").last.map(String.init) ?? source
        let stem = base.contains(".") ? String(base[..<base.lastIndex(of: ".")!]) : base
        return stem + ".o"
    }

    private func parentDir(_ path: String) -> String {
        guard let slash = path.lastIndex(of: "/") else { return workDir }
        let dir = String(path[..<slash])
        return dir.isEmpty ? "/" : dir
    }

    private func uniquePreopens(_ dirs: [String]) -> [String] {
        var seen = Set<String>()
        return dirs.filter { seen.insert($0).inserted }
    }
}
