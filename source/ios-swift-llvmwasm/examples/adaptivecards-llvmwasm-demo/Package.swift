// swift-tools-version:6.0
//
// Proxy-only smoke demo for the LLVMWasmCore bridge. Exercises the pure-Swift control surface
// (manifest verification math + the WASI phase-split planner) with no external artifacts, so the
// Windows MSVC gate can build + run it and assert `PASS adaptivecards-llvmwasm-roundtrip`.
//
// Path-deps the vendored kit at ../.. and names it explicitly so the package identity is the
// manifest name ("LLVMWasm"), not the enclosing directory basename. LLVMWasmCore has no external
// package dependencies, so there is nothing else to declare.

import PackageDescription

let package = Package(
    name: "AdaptiveCardsLLVMWasmDemo",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "adaptivecards-llvmwasm-demo", targets: ["adaptivecards-llvmwasm-demo"]),
    ],
    dependencies: [
        .package(name: "LLVMWasm", path: "../.."),
    ],
    targets: [
        .executableTarget(
            name: "adaptivecards-llvmwasm-demo",
            dependencies: [
                .product(name: "LLVMWasmCore", package: "LLVMWasm"),
            ]
        ),
    ]
)
