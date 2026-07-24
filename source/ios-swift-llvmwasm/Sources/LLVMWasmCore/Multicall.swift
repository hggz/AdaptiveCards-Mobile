//
//  Multicall.swift
//  LLVMWasmCore
//
//  The unified `llvm.wasm` module is a *multicall* binary: which tool runs is decided by `argv[0]`.
//  On disk the upstream ships these as symlinks to one module; under a Wasm engine (no symlinks,
//  no exec) the host selects the tool by prepending the chosen name as `argv[0]`. Pure Swift.
//

/// A tool personality exposed by the unified `llvm.wasm` multicall driver.
public enum Multicall: String, CaseIterable, Sendable {
    case clang
    case clangxx      = "clang++"
    case lld
    case ldLLD        = "ld.lld"
    case ld64LLD      = "ld64.lld"
    case lldLink      = "lld-link"
    case wasmLD       = "wasm-ld"
    case llvmAr       = "llvm-ar"
    case llvmNM       = "llvm-nm"
    case llvmObjdump  = "llvm-objdump"
    case llvmRanlib   = "llvm-ranlib"
    case llvmStrip    = "llvm-strip"

    /// The `argv[0]` value the host must present so the driver dispatches to this tool.
    public var argv0: String { rawValue }

    /// The linker personality appropriate for a WebAssembly target.
    public static var wasmLinker: Multicall { .wasmLD }
}
