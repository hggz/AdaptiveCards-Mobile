//
//  main.swift
//  adaptivecards-llvmwasm-demo
//
//  Round-trips the LLVMWasmCore control surface end to end without any external artifact:
//    1. the pure-Swift SHA-256 matches the FIPS 180-4 test vector,
//    2. the pinned toolchain-v1 manifest is well-formed and its verifier rejects bad bytes,
//    3. the WASI phase-split planner emits the expected multicall + I/O-rewrite contract.
//  On success it prints `PASS adaptivecards-llvmwasm-roundtrip`; any failure exits non-zero.
//

import Foundation
import LLVMWasmCore

func check(_ condition: Bool, _ message: String) {
    if !condition {
        FileHandle.standardError.write(Data("FAIL adaptivecards-llvmwasm-roundtrip: \(message)\n".utf8))
        exit(1)
    }
}

// 1. SHA-256 self-test against the classic "abc" vector.
let abc = ToolchainManifest.sha256Hex(Data("abc".utf8))
check(abc == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
      "SHA-256(\"abc\") = \(abc)")

// 2. Pinned manifest is well-formed.
let m = ToolchainManifest.toolchainV1
check(m.assets.count == 2, "expected 2 assets")
check(m.driverModule.sha256.count == 64, "driver digest must be 64 hex chars")
check(m.driverModule.byteCount == 75_538_735, "driver byte count pin")
check(m.wasiPortabilityCommit == "97196c8eeb", "WASI portability commit pin")
check(m.downloadURL(for: m.sysroot)
        == "https://github.com/hggz/llvm-wasm/releases/download/toolchain-v1/wasi-sysroot.tar.gz",
      "sysroot download URL")

// The verifier must reject bytes whose length doesn't match the pin.
do {
    try m.verify(m.driverModule, reading: { Data([0x00, 0x01, 0x02]) })
    check(false, "verifier accepted wrong-sized bytes")
} catch let ToolchainManifest.VerificationError.byteCountMismatch(expected, actual) {
    check(expected == 75_538_735 && actual == 3, "byte-count mismatch surfaced")
} catch {
    check(false, "unexpected verify error: \(error)")
}

// 3. Phase-split planner: a two-source C++ compile + link.
let planner = InvocationPlanner(workDir: "/work")
let request = CompileRequest(
    sources: ["/tmp/hello.cpp", "/tmp/util.cpp"],
    language: .cpp,
    output: "/work/hello.wasm",
    sysroot: "/work/sysroot/usr"
)
let plan = planner.plan(request)

check(plan.phases.count == 3, "expected 2 compiles + 1 link, got \(plan.phases.count)")

for compile in plan.phases.prefix(2) {
    check(compile.tool == .clangxx, "C++ compile must select clang++ (argv0=\(compile.argv0))")
    check(compile.args.contains("-fno-exceptions") && compile.args.contains("-fno-rtti"),
          "C++ compile must disable EH/RTTI (no-exceptions libc++abi)")
    check(compile.args.suffix(2) == ["-o", "-"], "compile must emit to stdout for WASI")
    check(compile.captureStdoutToHostFile?.hasPrefix("/work/") == true,
          "compile object must be rewritten under the work dir, not /tmp")
}

let link = plan.phases[2]
check(link.tool == .wasmLD, "link must select wasm-ld")
check(link.captureStdoutToHostFile == "/work/hello.wasm", "link output host file")
check(link.args.contains("--stack-first") && link.args.contains("--max-memory=4294967296"),
      "link must carry the pinned wasm memory/stack flags")
check(plan.advisories.contains { $0.contains("fork/exec") },
      "plan must advise the no-fork/exec contract")

// Multicall coverage sanity.
check(Multicall.wasmLinker == .wasmLD, "wasm linker personality")
check(Multicall.allCases.contains(.llvmAr), "multicall must expose llvm-ar")

print("PASS adaptivecards-llvmwasm-roundtrip")
