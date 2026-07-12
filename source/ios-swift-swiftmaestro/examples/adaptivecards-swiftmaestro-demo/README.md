# Adaptive Cards + swiftmaestro runtime proof

This Flavor C (runtime) example proves that the vendored swiftmaestro targets
can be imported, linked, and executed against a real Adaptive Card payload.
For this flow runtime, the four asserted executor events replace the agent-loop
event sequence used by provider-based Flavor C kits.

The executable decodes the canonical AdaptiveCards.io 1.5 Hello World sample,
projects its first `TextBlock` into a normalized hierarchy, parses and executes a
four-step Maestro flow, evaluates JavaScript through Duktape, verifies the tap
coordinates, generates a JSON report, and requires the report to record one
passing flow.

Success prints:

```text
PASS adaptivecards-swiftmaestro-runtime
```

## Symbols exercised

- `FlowParser.parse(_:sourcePath:)`
- `Selector.init(text:)`
- `Driver`
- `ViewNode`, `ViewHierarchy`, `Bounds`, and `Point`
- `ElementFinder.findFirst(_:in:requireVisible:)`
- `FlowExecutor.execute(_:on:device:options:)`
- `TestReport`
- `JSONReportGenerator.generate(_:)`

The demo calls substantially more than three public symbols and exercises the
full parser → selector → executor → JavaScript → driver → report path.

## Run

Windows uses the package's vcpkg zlib installation:

```powershell
pwsh -File smoke.ps1 -ZlibInc <include> -ZlibLib <lib>
```

Linux/macOS with a host zlib installation:

```sh
bash smoke.sh
```
