# swiftbox — proxy-only Swift bridge for AdaptiveCards-Mobile

This subfolder is an **experimental, proxy-only** vendored snapshot of
**swiftbox's** pure-Swift core (`SwiftboxCore`). It is a parallel Swift surface
dropped alongside the production mobile SDK — it does **not** alter or wrap any
existing iOS ObjC (`source/ios`), Android Java (`source/android`), or shared C++
(`source/shared`) code.

- **Vendored:** 2026-06-17
- **License:** inherits the repo-root **MIT** license. There is no nested
  `LICENSE` file and no per-file license headers.
- **Substrate pins:** none. `SwiftboxCore` is **pure cross-platform
  `Foundation` Swift** with **zero external package dependencies**, so the
  vendored `Package.swift` declares only the local `SwiftboxCore` target — there
  are no `.package(url:)` lines and therefore no SSH-alias URLs for CI to
  resolve. No `import Darwin / UIKit / AppKit / CoreFoundation / Combine / os.*`.

## What swiftbox is

swiftbox is a Termux-style terminal environment that runs entirely in-process
(no `fork`/`exec`), modelled as pure Swift so it works identically on iOS,
macOS, Linux, and Windows. `SwiftboxCore` provides:

- `VirtualFileSystem` — an in-memory POSIX-like filesystem (the userland
  `$PREFIX`).
- `Shell` + builtins — a command interpreter over that filesystem.
- `SwiftboxEnvironment` — the top-level façade that bootstraps the `$PREFIX`
  userland and wires the filesystem, package repository, and shell together.

## How it relates to AdaptiveCards

The bridge stores and round-trips an Adaptive Card JSON payload through
swiftbox's in-process sandbox: the card is written into the `VirtualFileSystem`,
read back through both the filesystem API and the `Shell`'s `cat` builtin, and
asserted byte-identical. This proves the vendored snapshot's core symbols link
and run end-to-end on Windows MSVC.

## Build (Windows MSVC)

```pwsh
swift build -c debug
```

No vcpkg / zlib is required (pure Foundation).

## True WSL/Linux → Windows cross-build → Wine round trip

The local extended lane uses Linux Swift 6.3.1 in WSL/Docker to compile this
bridge's `AdaptiveCardsDemo` for `x86_64-unknown-windows-msvc`, links the PE with
Linux `lld-link`, and runs that cross-built executable under Wine. The native
Windows Swift compiler does not participate in the build.

Prerequisites are the normal Windows Swift 6.3.1 installation, Visual Studio C++
tools + Windows SDK, WSL2, and Docker. From this directory in WSL:

```bash
scripts/xwin-roundtrip.sh
```

`prepare-xwin-sdk.ps1` discovers the version-matched split target SDK and stages
a generated, case-insensitive header/module-map overlay under ignored `dist/`.
The Docker lane then:

1. builds and runs `AdaptiveCardsDemo` natively on Linux;
2. cross-builds `AdaptiveCardsDemo.exe` for Windows from Linux;
3. runs that PE under Wine and requires `PASS adaptivecards-swiftbox-roundtrip`;
4. compares the Linux and Wine output byte-for-byte.

Confirmed locally on 2026-07-12: both outputs have SHA-256
`c3a173b7347d744852c0c57c59a6bb85c99ee40fd3bdf9427694548d6ec2a489`.
Generated PE/log artifacts are written to `dist/xwin-output/` and never committed.

## Symbols exercised

See `examples/adaptivecards-swiftbox-demo/README.md` for the runtime
symbol-check demo and the list of `SwiftboxCore` symbols it calls.
