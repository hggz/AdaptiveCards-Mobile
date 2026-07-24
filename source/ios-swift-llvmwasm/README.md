# ios-swift-llvmwasm — LLVMWasmCore

> **Proxy-only, experimental.** This is one of the `source/ios-swift-*` parallel Swift surfaces that
> ride alongside the production mobile SDK on the `proxy/*` branches. It touches none of the
> production ObjC (`source/ios`), Java (`source/android`), or C++ (`source/shared`) and ships on no
> `clean/*` branch or any PR targeting `microsoft/main`.

`LLVMWasmCore` is a **pure-Swift control surface** for a wasm-hosted LLVM/Clang/LLD toolchain — a
full C/C++ compiler + linker that has itself been compiled to WebAssembly (`wasm32-wasip1`) and runs
anywhere a Wasm engine runs. The Swift package is the portable *driver and manifest*: it locates,
verifies, and plans invocations of the toolchain. The heavy binaries are **not vendored** here; they
are distributed as release assets and pinned by SHA-256 (see [Distribution](#distribution)).

Like `SwiftboxCore`, this module is **pure cross-platform `Foundation`** — no
`Darwin`/`UIKit`/`AppKit`/`CoreFoundation`/`Combine`/`os.*` imports — and has **zero external package
dependencies**, so it builds and tests on **Windows MSVC** in CI with nothing to resolve over the
network.

## Platforms

| Platform | Status |
|---|---|
| macOS / iOS / tvOS / watchOS / visionOS | ✅ first-class (pure Foundation) |
| Linux (Swift 5.10 / 6.x) | ✅ first-class |
| Windows (MSVC, Swift 6.3.x) | ✅ first-class — gated in CI |

## Why the binaries aren't in the package

A pure-Swift package that must build on Windows MSVC cannot carry a 72 MB Wasm module (and a Wasm
compiler is not "pure Swift"). So the split is deliberate:

- **This package** = the portable, buildable-everywhere *control plane*: the pinned manifest, the
  multicall tool map, and the WASI phase-split invocation planner.
- **The toolchain binaries** = build artifacts, distributed as **release assets** and reproducible
  from source.

## What's inside

- **`ToolchainManifest`** — pinned coordinates of the `hggz/llvm-wasm` `toolchain-v1` release:
  asset names, SHA-256 digests, byte counts, the LLVM version, the upstream base commit, and the one
  WASI-portability commit. Includes `downloadURL(for:)` and an I/O-free `verify(_:reading:)`
  (backed by a dependency-free `SHA256`).
- **`Multicall`** — the tool personalities the single `llvm.wasm` module exposes via `argv[0]`
  dispatch (`clang`, `clang++`, `wasm-ld`, `llvm-ar`, `llvm-nm`, …).
- **`InvocationPlanner` / `InvocationPlan`** — models the **WASI phase-split contract**: a
  no-fork/exec Wasm compiler cannot spawn `cc1`/`wasm-ld`, so each phase is its own engine
  invocation. The planner emits the ordered phases, the `argv[0]` selection, and the two WASI I/O
  workarounds (emit-to-stdout because WASI can't seek-write; rewrite `/tmp/*` under a preopened work
  dir). It also auto-attaches `-fno-exceptions -fno-rtti` for C++ (the bundled `libc++abi` is a
  no-exceptions WASI build).

## Distribution

Binaries live on the reproducible-build repo, pinned here in `ToolchainManifest.toolchainV1`:

| asset | bytes | sha256 |
|-------|------:|--------|
| `llvm.wasm` | 75,538,735 | `a4944b56…4cd29ddb7` |
| `wasi-sysroot.tar.gz` | 4,058,612 | `d9265c36…2d179caa76` |

```bash
gh release download toolchain-v1 -R hggz/llvm-wasm
sha256sum -c SHA256SUMS.txt
```

Full recreate-from-source instructions and the smoke harness live in the `hggz/llvm-wasm` repo.

## Build & smoke

```bash
swift build -c debug                                  # the kit (pure Foundation)
examples/adaptivecards-llvmwasm-demo/smoke.sh         # build + run + assert PASS  (Linux/macOS)
examples/adaptivecards-llvmwasm-demo/smoke.ps1        # same, Windows MSVC
```

The demo round-trips the control surface with **no external artifact**: it checks the pure-Swift
SHA-256 against the FIPS test vector, validates the pinned manifest (and that its verifier rejects
bad bytes), and asserts the planner emits the expected multicall + I/O-rewrite contract, printing
`PASS adaptivecards-llvmwasm-roundtrip`.

CI gate: [`.github/workflows/swift-llvmwasm-bridge-gate.yml`](../../.github/workflows/swift-llvmwasm-bridge-gate.yml).
