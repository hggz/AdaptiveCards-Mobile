# adaptivecards-llvmwasm-demo

Symbol-check / round-trip smoke for `LLVMWasmCore`. It exercises the pure-Swift control surface with
**no external artifact** (the 72 MB `llvm.wasm` is not needed here), so the Windows MSVC gate can
build and run it quickly:

1. the dependency-free `SHA256` matches the FIPS 180-4 `"abc"` test vector;
2. the pinned `ToolchainManifest.toolchainV1` is well-formed and its `verify(_:reading:)` rejects
   wrong-sized bytes;
3. the `InvocationPlanner` emits the expected WASI phase-split contract — `clang++` compiles with
   `-fno-exceptions -fno-rtti`, objects are rewritten out of `/tmp` under the work dir and emitted to
   stdout, and `wasm-ld` links with the pinned memory/stack flags.

On success it prints `PASS adaptivecards-llvmwasm-roundtrip`.

```bash
./smoke.sh      # Linux/macOS
./smoke.ps1     # Windows MSVC
```
