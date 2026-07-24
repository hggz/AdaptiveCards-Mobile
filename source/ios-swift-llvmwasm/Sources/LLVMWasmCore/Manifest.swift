//
//  Manifest.swift
//  LLVMWasmCore
//
//  The pinned, verifiable coordinates of the wasm-hosted LLVM/Clang/LLD toolchain.
//  Pure `Foundation` — builds on Windows MSVC. No I/O side effects beyond the caller-supplied
//  reader passed to `verify(assetAt:reading:)`.
//

import Foundation

/// A single downloadable toolchain artifact, pinned by SHA-256 and byte length.
public struct ToolchainAsset: Equatable, Sendable {
    public let name: String
    public let sha256: String
    public let byteCount: Int
    /// Human note on what the asset contains / how to unpack it.
    public let note: String

    public init(name: String, sha256: String, byteCount: Int, note: String) {
        self.name = name
        self.sha256 = sha256
        self.byteCount = byteCount
        self.note = note
    }
}

/// Everything a Swift-on-Windows host needs to *locate, verify, and reproduce* the toolchain.
///
/// The binaries are intentionally not vendored inside this pure-Swift package (a 72 MB Wasm
/// module cannot ride inside a package that must build on Windows MSVC). They are published as
/// release assets and described here. `LLVMWasmCore` is the portable control surface; the heavy
/// artifacts are fetched out-of-band and checked against these pins.
public struct ToolchainManifest: Sendable {

    // MARK: Provenance

    /// GitHub `owner/repo` that hosts the release assets and the reproducible build scripts.
    public let repository: String
    /// Release tag carrying the pinned assets.
    public let releaseTag: String
    /// LLVM version the module was cut from.
    public let llvmVersion: String
    /// Upstream base commit in `YoWASP/llvm-project` the build started from.
    public let llvmBaseCommit: String
    /// The single WASI-portability commit layered on top of the base.
    public let wasiPortabilityCommit: String
    /// Compilation target triple the toolchain itself was built for.
    public let hostTriple: String
    /// Default target triple the toolchain cross-compiles *to*.
    public let defaultTargetTriple: String

    // MARK: Assets

    /// The unified multicall driver module (`clang`, `clang++`, `lld`, `wasm-ld`, `llvm-ar`, … all
    /// dispatch from this one module on `argv[0]`).
    public let driverModule: ToolchainAsset
    /// The target sysroot tarball (headers + `libc.a`/`libc++.a`/`libc++abi.a` + compiler-rt + crt).
    public let sysroot: ToolchainAsset

    public var assets: [ToolchainAsset] { [driverModule, sysroot] }

    /// Canonical `https://github.com/{repo}/releases/download/{tag}/{asset}` URL for an asset.
    public func downloadURL(for asset: ToolchainAsset) -> String {
        "https://github.com/\(repository)/releases/download/\(releaseTag)/\(asset.name)"
    }

    // MARK: Verification

    public enum VerificationError: Error, Equatable {
        case byteCountMismatch(expected: Int, actual: Int)
        case digestMismatch(expected: String, actual: String)
    }

    /// Verify a downloaded asset's bytes against its pinned length and SHA-256.
    /// `reading` is caller-supplied so the core stays I/O-free and testable on any platform.
    public func verify(_ asset: ToolchainAsset, reading loadBytes: () throws -> Data) throws {
        let data = try loadBytes()
        guard data.count == asset.byteCount else {
            throw VerificationError.byteCountMismatch(expected: asset.byteCount, actual: data.count)
        }
        let digest = Self.sha256Hex(data)
        guard digest == asset.sha256 else {
            throw VerificationError.digestMismatch(expected: asset.sha256, actual: digest)
        }
    }

    // MARK: Pinned instance

    /// The `toolchain-v1` release of `hggz/llvm-wasm`, verified 2026.
    public static let toolchainV1 = ToolchainManifest(
        repository: "hggz/llvm-wasm",
        releaseTag: "toolchain-v1",
        llvmVersion: "22.1.0",
        llvmBaseCommit: "4434dabb69",
        wasiPortabilityCommit: "97196c8eeb",
        hostTriple: "wasm32-wasip1",
        defaultTargetTriple: "wasm32-wasip1",
        driverModule: ToolchainAsset(
            name: "llvm.wasm",
            sha256: "a4944b5688c03abd9a2fdbc0ca6d9f54bf0379cf8d884e55b9d204e4cd29ddb7",
            byteCount: 75_538_735,
            note: "Unified multicall driver; symlink/argv0 dispatch to clang, clang++, lld, "
                + "ld.lld, ld64.lld, lld-link, wasm-ld, llvm-ar, llvm-nm, llvm-objdump, "
                + "llvm-ranlib, llvm-strip."
        ),
        sysroot: ToolchainAsset(
            name: "wasi-sysroot.tar.gz",
            sha256: "d9265c36e8f96fedb47e05314d7054ff58780bcc94ed79ade854382d179caa76",
            byteCount: 4_058_612,
            note: "Extract to get usr/: headers + libc.a, libc++.a, libc++abi.a, compiler-rt "
                + "builtins, crt1*.o, wasi-emulated-{mman,signal,getpid,process-clocks}.a."
        )
    )
}
