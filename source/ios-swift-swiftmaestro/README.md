# ios-swift-swiftmaestro — proxy-only runtime bridge

This directory is a vendored, importable snapshot of the cross-platform
swiftmaestro runtime from `hggz/swiftmaestro`, added alongside Adaptive Cards
Mobile as an experimental proxy-only Swift surface. Vendored as of 2026-07-12.
It does not modify or wrap the production Objective-C, Java, or C++ SDKs.

The drop keeps the general-purpose parser → driver contract → executor → report
pipeline, embedded JavaScript runtime, and every importable concrete backend. A
host may provide its own `Driver` or directly use UIAutomator2, Browser/CDP,
DeviceLab, WDA, or Appium to automate an Adaptive Card surface.

## Importable products

| Product | Purpose |
|---|---|
| `SwiftMaestroFlow` | Maestro YAML model, parser, selectors, and validation |
| `SwiftMaestroDriver` | Cross-platform driver protocol, normalized hierarchy, and element finder |
| `SwiftMaestroReport` | Deterministic JSON, JUnit, HTML, and Allure reports |
| `SwiftMaestroJS` | Embedded Duktape scripting, interpolation, `output.*`, and HTTP binding |
| `SwiftMaestroRunner` | Flow execution, dynamic driver pools, and report orchestration |
| `SwiftMaestroBrowser` | Chrome/Chromium/Edge over CDP WebSocket |
| `SwiftMaestroDeviceLab` | Android DeviceLab WebSocket backend |
| `SwiftMaestroWDA` | Portable WebDriverAgent HTTP backend + macOS host tooling |
| `SwiftMaestroAppium` | Appium W3C driver and cloud capability builders |

The ArgumentParser command-line executable and repository-specific fixture
harness are intentionally omitted, matching the sibling SwiftPi drop's
library-without-CLI pattern. All nine public library products build on Windows;
portable HTTP/driver behavior is hermetically tested on Windows, while actual
Xcode/simulator orchestration remains runtime-gated to macOS.

swiftmaestro is a **host-side** package. It runs on Windows, Linux, and macOS and
drives iOS through WDA/Appium; it is not linked into an iOS application binary.

## Adaptive Cards runtime proof

`examples/adaptivecards-swiftmaestro-demo` is a separate consumer package. It:

1. decodes the canonical AdaptiveCards.io 1.5 Hello World payload;
2. maps its first `TextBlock` into a demo-local `ViewHierarchy`;
3. parses a real Maestro YAML flow containing selector, tap, JavaScript, and
   assertion steps;
4. executes the flow through a demo-local `Driver` implementation;
5. verifies the exact passed-step sequence and tap point;
6. generates and decodes a deterministic JSON report; and
7. prints `PASS adaptivecards-swiftmaestro-runtime`.

This proves the vendored symbols parse, link, and execute together. It does not
claim that the cross-platform runtime itself renders UIKit views; production
card rendering remains in AdaptiveCards-Mobile's native SDK.

## Build and test — Windows MSVC

Swift 6.3.1 and zlib from vcpkg manifest mode are required. From this directory:

```powershell
$triplet = 'x64-windows-static-md'
& "$env:VCPKG_INSTALLATION_ROOT\vcpkg.exe" install --triplet $triplet
$inc = (Resolve-Path "vcpkg_installed\$triplet\include").Path
$lib = (Resolve-Path "vcpkg_installed\$triplet\lib").Path
$flags = @('-Xcc', "-I$inc", '-Xswiftc', "-I$inc", '-Xlinker', "/LIBPATH:$lib")

swift build -c debug @flags
swift test --parallel @flags
pwsh -File examples/adaptivecards-swiftmaestro-demo/smoke.ps1 `
  -ZlibInc $inc -ZlibLib $lib
```

The package carries 188 hermetic XCTest cases covering flow parsing/validation,
element finding, reports, Process, real Duktape scripting, execution, managed
lifecycle, dynamic work distribution, UIAutomator2, Browser/CDP, DeviceLab,
WDA, Appium, cloud security, and cleanup when pooled-driver setup or
installation fails. All network tests use loopback mock servers.

## Dependency posture

All network dependencies use public HTTPS URLs. Yams is the YAML parser. The
Windows networking substrate is pinned to the public hggz forks of swift-nio,
swift-nio-extras, swift-nio-ssl, and async-http-client. There are no private
package references, SSH URLs, Apple-only imports, package lockfiles, or nested
repositories in this drop.

## Snapshot boundary

The vendored profile intentionally omits only the CLI, deterministic example
harness, and external-system smoke applications. See `docs/PROVENANCE.md` for
the retained module boundary.

## Licensing

The translated swiftmaestro/maestro-runner material remains Apache-2.0 and the
embedded Duktape engine remains MIT. The complete Apache terms and attribution
are in `NOTICE.md`; Duktape's complete MIT notice and author list remain embedded
verbatim in its generated sources and headers. New integration glue and demo
files are covered by AdaptiveCards-Mobile's repository-root MIT License. No
nested file named `LICENSE` is included.
