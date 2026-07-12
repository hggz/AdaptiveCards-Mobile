# Vendored runtime provenance

This proxy-only package is a selected snapshot of `hggz/swiftmaestro`, an
Apache-2.0 Swift translation of the host-side engine in
`devicelab-dev/maestro-runner`. Files translated from upstream retain a `Port
of:` comment. The snapshot date is 2026-07-12; no private source-repository
commit identifier is recorded.

| Vendored target | Upstream area | Included capability |
|---|---|---|
| `SwiftMaestroFlow` | `pkg/flow`, `pkg/validator` | Flow model, parser, selectors, validation |
| `SwiftMaestroDriver` | `pkg/core`, `pkg/driver` | Driver contract, hierarchy, element finder, managed lifecycle |
| `SwiftMaestroReport` | `pkg/report` | JSON/JUnit/HTML/Allure generation |
| `SwiftMaestroJSEngine` | Duktape 2.7.0 + original shim | Embedded JavaScript C engine |
| `SwiftMaestroJS` | `pkg/jsengine` | Script host, values, interpolation, HTTP binding |
| `SwiftMaestroRunner` | `pkg/executor` | Execution, dynamic work queue, test/report orchestration |
| `SwiftMaestroProcess` | `pkg/device` | Cross-platform process execution used by host backends |
| `SwiftMaestroDriver` concrete files | `drivers/uiautomator2`, `pkg/emulator` | Android UIAutomator2 + managed emulator support |
| `SwiftMaestroBrowser` | `drivers/cdp`, `pkg/browser` | Browser/CDP backend |
| `SwiftMaestroDeviceLab` | `drivers/devicelab` | DeviceLab WebSocket backend |
| `SwiftMaestroWDA` | `drivers/wda`, `pkg/wda`, `pkg/simulator` | WDA backend + macOS host orchestration |
| `SwiftMaestroAppium` | `drivers/appium`, `pkg/cloud` | Appium and cloud capabilities |

The drop deliberately omits command-line targets, the deterministic example
harness, and raw external-system smoke applications. Consumers may use any
vendored backend or provide a `Driver` appropriate to their Adaptive Cards
surface.

No source under AdaptiveCards-Mobile's existing `source/ios`, `source/android`,
or `source/shared/cpp` trees is changed by this bridge.
