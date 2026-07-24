// swift-tools-version:5.9
//
// Vendored, proxy-only pure-Swift **control surface** for the wasm-hosted LLVM/Clang/LLD
// toolchain (hggz/llvm-wasm). Like the other `ios-swift-*` bridges it is an experimental,
// proxy-only parallel Swift surface dropped alongside the production mobile SDK — it touches
// none of the production ObjC (`source/ios`), Java (`source/android`), or C++ (`source/shared`).
//
// `platforms` only narrows minimum versions for Apple platforms. Linux, Windows, and any other
// Swift-supported target build with no platform clause — so this deliberately does NOT restrict to
// Apple. `LLVMWasmCore` is pure cross-platform `Foundation` Swift (no Darwin/UIKit/AppKit/
// CoreFoundation/Combine/os.* imports), so it builds and tests on **Windows MSVC**.
//
// LLVMWasmCore has NO external package dependencies (no `.package(url:)` lines, hence no SSH-alias
// URLs to resolve in CI). It does NOT vendor the 72 MB `llvm.wasm` module or the WASI sysroot —
// those are build artifacts distributed as **release assets** (hggz/llvm-wasm `toolchain-v1`) and
// are described here by `ToolchainManifest`. This package is the portable driver/manifest that a
// Swift-on-Windows host uses to *locate, verify, and drive* that toolchain under a Wasm engine.

import PackageDescription

let package = Package(
    name: "LLVMWasm",
    platforms: [
        .iOS(.v16), .macOS(.v13), .tvOS(.v16),
        .watchOS(.v9), .visionOS(.v1),
    ],
    products: [
        .library(name: "LLVMWasmCore", targets: ["LLVMWasmCore"]),
    ],
    targets: [
        .target(name: "LLVMWasmCore"),
    ]
)
