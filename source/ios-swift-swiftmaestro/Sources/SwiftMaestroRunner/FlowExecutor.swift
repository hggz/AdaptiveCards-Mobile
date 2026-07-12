// Port of: pkg/executor + pkg/core (execution) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroFlow
import SwiftMaestroDriver
import SwiftMaestroReport
import SwiftMaestroJS

/// Executes a parsed `Flow` against a `Driver`, resolving selectors with the
/// element finder and producing a `FlowResult`. Commands not yet wired to a
/// backend behavior (clipboard, media, recording, JS scripting) are reported as
/// `.skipped` rather than failing the flow.
public struct FlowExecutor: Sendable {
    public struct Options: Sendable {
        public var commandTimeoutMs: Int
        public var flowTimeoutMs: Int?
        public var waitForIdleTimeoutMs: Int
        public init(commandTimeoutMs: Int = 10_000,
                    flowTimeoutMs: Int? = nil,
                    waitForIdleTimeoutMs: Int = 3_000) {
            self.commandTimeoutMs = commandTimeoutMs
            self.flowTimeoutMs = flowTimeoutMs
            self.waitForIdleTimeoutMs = waitForIdleTimeoutMs
        }
    }

    private let finder = ElementFinder()
    private let scriptingEnabled: Bool
    private let httpBinding: (any HTTPBinding)?

    public init(scriptingEnabled: Bool = true, httpBinding: (any HTTPBinding)? = nil) {
        self.scriptingEnabled = scriptingEnabled
        self.httpBinding = httpBinding
    }

    /// A per-flow interpolation + scripting scope. When enabled, one JS
    /// `ScriptHost` persists across the whole flow so `output` and injected env
    /// vars carry between steps; `interp` is the no-JS fallback.
    struct Scope: Sendable {
        var interp: Interpolator
        let scripting: ScriptHost?
        var sourcePath: String?
        let clipboard: ExecutionClipboard
    }

    /// Execute every step in order. A non-optional step failure aborts the flow
    /// (remaining steps are marked `.skipped`).
    public func execute(_ flow: Flow,
                        on driver: any Driver,
                        device: String? = nil,
                        options: Options = .init()) async -> FlowResult {
        let scripting = await makeScriptHost(env: flow.env)
        let scope = Scope(interp: Interpolator(env: flow.env), scripting: scripting,
                          sourcePath: flow.sourcePath, clipboard: ExecutionClipboard())
        let commandTimeout = max(0, flow.commandTimeout ?? options.commandTimeoutMs)
        let flowTimeout = max(0, flow.flowTimeout ?? options.flowTimeoutMs ?? 0)
        let idleTimeout = max(0, flow.waitForIdleTimeout ?? options.waitForIdleTimeoutMs)
        let effectiveOptions = Options(commandTimeoutMs: commandTimeout,
                           flowTimeoutMs: flowTimeout,
                           waitForIdleTimeoutMs: idleTimeout)
        let flowStarted = Date()
        var results: [StepResult] = []
        var status: RunStatus = .passed
        var flowMessage: String?
        var aborted = false

        for step in flow.steps {
            if aborted {
                results.append(StepResult(command: step.commandName, label: label(of: step), status: .skipped, durationMs: 0))
                continue
            }
            let started = Date()
            do {
                let elapsedFlow = elapsedMs(since: flowStarted)
                if flowTimeout > 0, elapsedFlow >= flowTimeout {
                    throw DriverError.timedOut("flow exceeded \(flowTimeout)ms")
                }
                let remainingFlow = flowTimeout > 0 ? max(1, flowTimeout - elapsedFlow) : 0
                let timeout = commandTimeout > 0 && remainingFlow > 0
                    ? min(commandTimeout, remainingFlow)
                    : max(commandTimeout, remainingFlow)
                let limitedByFlow = flowTimeout > 0 &&
                    (commandTimeout == 0 || remainingFlow <= commandTimeout)
                let watchdog = timeout > 0 && !limitedByFlow && !Self.managesOwnTimeout(step)
                    ? timeout + min(100, max(20, timeout / 10))
                    : (Self.managesOwnTimeout(step) ? 0 : timeout)
                var configuredOptions = effectiveOptions
                configuredOptions.commandTimeoutMs = timeout
                let stepOptions = configuredOptions
                let outcome = try await withTimeout(watchdog, reportedMilliseconds: timeout,
                                                    command: step.commandName) {
                    let outcome = try await run(step, on: driver, scope: scope,
                                                options: stepOptions)
                    if idleTimeout > 0 { try await driver.waitForIdle(timeoutMs: idleTimeout) }
                    return outcome
                }
                results.append(StepResult(command: step.commandName, label: label(of: step),
                                          status: outcome, durationMs: elapsedMs(since: started)))
            } catch let error as DriverError where Self.isNotSupported(error) {
                results.append(StepResult(command: step.commandName, label: label(of: step),
                                          status: .skipped, durationMs: elapsedMs(since: started),
                                          message: "\(error)"))
            } catch {
                let message = "\(error)"
                if isOptional(step) {
                    results.append(StepResult(command: step.commandName, label: label(of: step),
                                              status: .skipped, durationMs: elapsedMs(since: started),
                                              message: message))
                } else {
                    results.append(StepResult(command: step.commandName, label: label(of: step),
                                              status: .failed, durationMs: elapsedMs(since: started),
                                              message: message))
                    status = .failed
                    flowMessage = message
                    aborted = true
                }
            }
        }

        let duration = results.reduce(0) { $0 + $1.durationMs }
        return FlowResult(name: flow.name ?? defaultName(for: flow),
                          filePath: flow.sourcePath,
                          appId: flow.appId,
                          tags: flow.tags,
                          device: device,
                          status: status,
                          durationMs: duration,
                          message: flowMessage,
                          steps: results)
    }

    // MARK: - Step dispatch

    private func run(_ step: MaestroStep,
                     on driver: any Driver,
                     scope: Scope,
                     options: Options) async throws -> RunStatus {
        switch step {
        case .launchApp(let s):
            try await driver.launchApp(s.appId ?? "", arguments: stringArgs(s.arguments))
            return .passed
        case .stopApp(let appId, _), .killApp(let appId, _):
            try await driver.stopApp(appId ?? "")
            return .passed
        case .clearState(let appId, _):
            try await driver.clearState(appId ?? "")
            return .passed
        case .clearKeychain:
            try await driver.clearKeychain()
            return .passed

        case .tapOn(let s):
            let point = try await resolvePoint(s.selector, on: driver,
                                               timeoutMs: options.commandTimeoutMs)
            for _ in 0..<max(1, s.repeatCount ?? 1) { try await driver.tap(point) }
            return .passed
        case .doubleTapOn(let s):
            let point = try await resolvePoint(s.selector, on: driver,
                                               timeoutMs: options.commandTimeoutMs)
            try await driver.tap(point)
            try await driver.tap(point)
            return .passed
        case .longPressOn(let s):
            try await driver.longPress(try await resolvePoint(s.selector, on: driver,
                                                              timeoutMs: options.commandTimeoutMs))
            return .passed

        case .inputText(let s):
            try await driver.inputText(await expand(s.text, scope))
            return .passed
        case .eraseText(let count, _):
            try await driver.eraseText(count ?? 50)
            return .passed
        case .copyTextFrom(let selector, _):
            let hierarchy = try await driver.viewHierarchy()
            let node = finder.findFirst(selector, in: hierarchy)?.node
            let nodeText = node?.text ?? node?.accessibilityId ?? node?.resourceId
            let nativeText: String?
            if nodeText == nil { nativeText = try await driver.nativeText(for: selector) }
            else { nativeText = nil }
            let text = nodeText ?? nativeText
            guard let text else { throw ExecutionError.elementNotFound("\(selector)") }
            await scope.clipboard.set(text)
            return .passed
        case .pasteText:
            guard let text = await scope.clipboard.get() else {
                throw DriverError.toolFailure("pasteText called before copyTextFrom")
            }
            try await driver.inputText(text)
            return .passed

        case .assertVisible(let s):
            guard try await waitForVisibility(s.selector, visible: true, on: driver,
                                              timeoutMs: effectiveTimeout(s.timeout,
                                                                          options.commandTimeoutMs)) else {
                throw ExecutionError.elementNotFound("\(s.selector)")
            }
            return .passed
        case .assertNotVisible(let s):
            if try await !waitForVisibility(s.selector, visible: false, on: driver,
                                            timeoutMs: effectiveTimeout(s.timeout,
                                                                        options.commandTimeoutMs)) {
                throw ExecutionError.assertionFailed("assertNotVisible failed: element is visible: \(s.selector)")
            }
            return .passed
        case .assertTrue(let condition, _):
            let expanded = await expand(condition, scope).trimmingCharacters(in: .whitespaces)
            if expanded == "true" { return .passed }
            if expanded == "false" { throw ExecutionError.assertionFailed("assertTrue failed: \(condition)") }
            if let scripting = scope.scripting {
                if await scripting.isTruthy(condition) { return .passed }
                throw ExecutionError.assertionFailed("assertTrue failed: \(condition)")
            }
            return .skipped

        case .scroll(let s):
            try await driver.scroll(s.direction)
            return .passed
        case .scrollUntilVisible(let s):
            let timeout = effectiveTimeout(s.timeout, options.commandTimeoutMs)
            let started = Date()
            var attempts = 0
            repeat {
                if try await isVisible(s.element, on: driver) { return .passed }
                try await driver.scroll(s.direction)
                attempts += 1
                try await Task.sleep(nanoseconds: 10_000_000)
            } while timeout > 0 ? elapsedMs(since: started) < timeout : attempts < 12
            guard try await isVisible(s.element, on: driver) else {
                throw ExecutionError.elementNotFound("\(s.element)")
            }
            return .passed
        case .swipe(let s):
            try await performSwipe(s, on: driver)
            return .passed

        case .back:
            try await driver.pressKey(.back)
            return .passed
        case .pressKey(let key, _):
            try await driver.pressKey(key)
            return .passed
        case .hideKeyboard:
            try await driver.hideKeyboard()
            return .passed

        case .openLink(let s):
            try await driver.openLink(await expand(s.url, scope))
            return .passed
        case .waitForAnimationToEnd(let timeout, _):
            try await driver.waitForIdle(timeoutMs: max(0, timeout ?? options.waitForIdleTimeoutMs))
            return .passed
        case .takeScreenshot(let screenshot):
            let data = try await driver.screenshot()
            if let path = screenshot.path { try writeScreenshot(data, path: path, scope: scope) }
            return .passed
        case .startRecording(let recording):
            let requested = recording.path ?? "recording"
            try await driver.startRecording(resolveReference(requested, relativeTo: scope.sourcePath))
            return .passed
        case .stopRecording:
            try await driver.stopRecording()
            return .passed
        case .setLocation(let lat, let lng, _):
            try await driver.setLocation(latitude: lat, longitude: lng)
            return .passed
        case .travel(let travel):
            for point in travel.points {
                try await driver.setLocation(latitude: point.latitude, longitude: point.longitude)
            }
            return .passed
        case .addMedia(let paths, _):
            try await driver.addMedia(paths.map { resolveReference($0, relativeTo: scope.sourcePath) })
            return .passed

        case .runFlow(let s):
            return try await runSubflow(s, on: driver, scope: scope, options: options)
        case .runScript(let s):
            return try await runScript(s, on: driver, scope: scope)
        case .evalScript(let script, _):
            guard let scripting = scope.scripting else { return .skipped }
            _ = try await scripting.run(Self.unwrapScriptExpression(script))
            return .passed
        case .`repeat`(let s):
            if let times = s.times {
                for _ in 0..<max(0, times) {
                    try await runSteps(s.commands, on: driver, scope: scope, options: options)
                }
                return .passed
            }
            guard let condition = s.whileCondition else {
                try await runSteps(s.commands, on: driver, scope: scope, options: options)
                return .passed
            }
            var iterations = 0
            while try await evaluate(condition, on: driver, scope: scope) {
                guard iterations < 1_000 else {
                    throw DriverError.timedOut("repeat while-condition exceeded 1000 iterations")
                }
                try await runSteps(s.commands, on: driver, scope: scope, options: options)
                iterations += 1
            }
            return .passed
        case .retry(let s):
            if let condition = s.whenCondition,
               try await !evaluate(condition, on: driver, scope: scope) {
                return .skipped
            }
            var attempt = 0
            let maxRetries = max(0, s.maxRetries ?? 1)
            while true {
                do {
                    try await runSteps(s.commands, on: driver, scope: scope, options: options)
                    return .passed
                } catch {
                    attempt += 1
                    if attempt > maxRetries { throw error }
                }
            }
        }
    }

    // MARK: - Container steps

    private func runSubflow(_ step: RunFlowStep,
                            on driver: any Driver,
                            scope: Scope,
                            options: Options) async throws -> RunStatus {
        if let condition = step.whenCondition, try await !evaluate(condition, on: driver, scope: scope) {
            return .skipped
        }
        if let file = step.file {
            let path = resolveReference(file, relativeTo: scope.sourcePath)
            let flow = try FlowParser.parse(contentsOf: path)
            var env = scope.interp.env
            for (k, v) in step.env { env[k] = v.description }
            if let scripting = scope.scripting, !step.env.isEmpty {
                var overrides: [String: String] = [:]
                for (k, v) in step.env { overrides[k] = v.description }
                await scripting.setEnvironment(overrides)
            }
            var childScope = scope
            childScope.interp = Interpolator(env: env)
            childScope.sourcePath = flow.sourcePath
            try await runSteps(flow.steps, on: driver, scope: childScope, options: options)
        }
        try await runSteps(step.commands, on: driver, scope: scope, options: options)
        return .passed
    }

    private func runScript(_ step: RunScriptStep,
                           on driver: any Driver,
                           scope: Scope) async throws -> RunStatus {
        if let condition = step.whenCondition, try await !evaluate(condition, on: driver, scope: scope) {
            return .skipped
        }
        guard let scripting = scope.scripting else { return .skipped }
        let path = resolveReference(step.file, relativeTo: scope.sourcePath)
        let source = try String(contentsOfFile: path, encoding: .utf8)
        if !step.env.isEmpty {
            var overrides: [String: String] = [:]
            for (k, v) in step.env { overrides[k] = v.description }
            await scripting.setEnvironment(overrides)
        }
        _ = try await scripting.run(source)
        return .passed
    }

    private func runSteps(_ steps: [MaestroStep],
                          on driver: any Driver,
                          scope: Scope,
                          options: Options) async throws {
        for step in steps {
            _ = try await run(step, on: driver, scope: scope, options: options)
        }
    }

    // MARK: - Selectors, gestures, conditions

    private func resolvePoint(_ selector: Selector,
                              on driver: any Driver,
                              timeoutMs: Int) async throws -> Point {
        let started = Date()
        repeat {
            let hierarchy = try await driver.viewHierarchy()
            if let match = finder.findFirst(selector, in: hierarchy), let bounds = match.node.bounds {
                return bounds.center
            }
            if let bounds = try await driver.nativeBounds(for: selector) { return bounds.center }
            if let point = selector.point { return screenPoint(point, in: hierarchy) }
            if timeoutMs == 0 { break }
            try await Task.sleep(nanoseconds: 10_000_000)
        } while elapsedMs(since: started) < timeoutMs
        throw ExecutionError.elementNotFound("\(selector)")
    }

    private func isVisible(_ selector: Selector, on driver: any Driver) async throws -> Bool {
        let hierarchy = try await driver.viewHierarchy()
        if finder.findFirst(selector, in: hierarchy, requireVisible: true) != nil { return true }
        return try await driver.nativeBounds(for: selector) != nil
    }

    private func waitForVisibility(_ selector: Selector,
                                   visible: Bool,
                                   on driver: any Driver,
                                   timeoutMs: Int) async throws -> Bool {
        let started = Date()
        repeat {
            if try await isVisible(selector, on: driver) == visible { return true }
            if timeoutMs == 0 { return false }
            try await Task.sleep(nanoseconds: 10_000_000)
        } while elapsedMs(since: started) < timeoutMs
        return false
    }

    private func performSwipe(_ s: SwipeStep, on driver: any Driver) async throws {
        let hierarchy = try await driver.viewHierarchy()
        let screen = hierarchy.root.bounds ?? Bounds(x: 0, y: 0, width: 1080, height: 1920)
        let duration = s.duration ?? 400

        if let start = s.start, let end = s.end {
            try await driver.swipe(from: screenPoint(start, in: hierarchy),
                                   to: screenPoint(end, in: hierarchy), durationMs: duration)
            return
        }
        var from = screen.center
        if let fromSelector = s.from, let match = finder.findFirst(fromSelector, in: hierarchy),
           let bounds = match.node.bounds {
            from = bounds.center
        }
        let direction = s.direction ?? .up
        try await driver.swipe(from: from, to: Self.offset(from, direction, in: screen), durationMs: duration)
    }

    private func evaluate(_ condition: Condition, on driver: any Driver, scope: Scope) async throws -> Bool {
        if let visible = condition.visible, try await !isVisible(visible, on: driver) { return false }
        if let notVisible = condition.notVisible, try await isVisible(notVisible, on: driver) { return false }
        if let platform = condition.platform, platform.lowercased() != driver.platform.rawValue { return false }
        if let expr = condition.trueExpression {
            let expanded = await expand(expr, scope).trimmingCharacters(in: .whitespaces)
            if expanded == "true" { return true }
            if expanded == "false" { return false }
            if let scripting = scope.scripting { return await scripting.isTruthy(expr) }
            return false
        }
        return true
    }

    // MARK: - Scripting

    /// Build the per-flow JS host (when scripting is enabled) and seed it with the
    /// flow `env`. Returns nil if scripting is disabled or the engine can't start,
    /// in which case the executor falls back to plain `${NAME}` expansion.
    private func makeScriptHost(env: [String: String]) async -> ScriptHost? {
        guard scriptingEnabled, let host = try? ScriptHost(http: httpBinding ?? AsyncHTTPBinding()) else {
            return nil
        }
        var merged = ProcessInfo.processInfo.environment
        for (key, value) in env { merged[key] = value }
        await host.setEnvironment(merged)
        return host
    }

    /// Expand `${…}` via the JS host when present, else the plain env resolver.
    private func expand(_ text: String, _ scope: Scope) async -> String {
        if let scripting = scope.scripting { return await scripting.expand(text) }
        return scope.interp.expand(text)
    }

    /// `evalScript` bodies are conventionally wrapped in `${…}`; strip that so the
    /// inner JavaScript is what the engine runs.
    private static func unwrapScriptExpression(_ script: String) -> String {
        let trimmed = script.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("${"), trimmed.hasSuffix("}") {
            return String(trimmed.dropFirst(2).dropLast())
        }
        return script
    }

    // MARK: - Timeouts / files

    private func withTimeout<T: Sendable>(_ milliseconds: Int,
                                          reportedMilliseconds: Int,
                                          command: String,
                                          operation: @escaping @Sendable () async throws -> T) async throws -> T {
        guard milliseconds > 0 else { return try await operation() }
        return try await withCheckedThrowingContinuation { continuation in
            let race = ExecutionTimeoutRace(continuation)
            Task {
                do { race.complete(.success(try await operation())) }
                catch { race.complete(.failure(error)) }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
                race.complete(.failure(DriverError.timedOut(
                    "\(command) exceeded \(reportedMilliseconds)ms"
                )))
            }
        }
    }

    private func resolveReference(_ path: String, relativeTo sourcePath: String?) -> String {
        if (path as NSString).isAbsolutePath { return path }
        guard let sourcePath else { return path }
        return URL(fileURLWithPath: sourcePath)
            .deletingLastPathComponent()
            .appendingPathComponent(path)
            .standardizedFileURL.path
    }

    private func writeScreenshot(_ data: Data, path: String, scope: Scope) throws {
        var resolved = resolveReference(path, relativeTo: scope.sourcePath)
        if (resolved as NSString).pathExtension.isEmpty { resolved += ".png" }
        let url = URL(fileURLWithPath: resolved)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try data.write(to: url, options: []) // non-atomic: replaceItemAt is unavailable on Windows
    }

    // MARK: - Geometry helpers

    private func screenPoint(_ p: PointExpr, in hierarchy: ViewHierarchy) -> Point {
        let screen = hierarchy.root.bounds ?? Bounds(x: 0, y: 0, width: 1080, height: 1920)
        let x = p.xIsPercent ? screen.x + Int(Double(screen.width) * p.x / 100.0) : Int(p.x)
        let y = p.yIsPercent ? screen.y + Int(Double(screen.height) * p.y / 100.0) : Int(p.y)
        return Point(x: x, y: y)
    }

    private static func offset(_ from: Point, _ direction: Direction, in screen: Bounds) -> Point {
        let dx = screen.width / 3
        let dy = screen.height / 3
        switch direction {
        case .up: return Point(x: from.x, y: max(screen.y, from.y - dy))
        case .down: return Point(x: from.x, y: min(screen.bottom, from.y + dy))
        case .left: return Point(x: max(screen.x, from.x - dx), y: from.y)
        case .right: return Point(x: min(screen.right, from.x + dx), y: from.y)
        }
    }

    // MARK: - Small helpers

    private func stringArgs(_ args: [String: ScalarValue]) -> [String: String] {
        var out: [String: String] = [:]
        for (k, v) in args { out[k] = v.description }
        return out
    }

    private func defaultName(for flow: Flow) -> String {
        if let path = flow.sourcePath { return (path as NSString).lastPathComponent }
        return flow.appId ?? "flow"
    }

    private func elapsedMs(since start: Date) -> Int {
        max(0, Int(Date().timeIntervalSince(start) * 1000))
    }

    private static func isNotSupported(_ error: DriverError) -> Bool {
        if case .notSupported = error { return true }
        return false
    }

    private static func managesOwnTimeout(_ step: MaestroStep) -> Bool {
        switch step {
        case .tapOn, .doubleTapOn, .longPressOn, .assertVisible, .assertNotVisible,
             .scrollUntilVisible:
            return true
        default:
            return false
        }
    }

    private func effectiveTimeout(_ explicit: Int?, _ fallback: Int) -> Int {
        let explicit = max(0, explicit ?? 0)
        let fallback = max(0, fallback)
        if explicit > 0, fallback > 0 { return min(explicit, fallback) }
        return max(explicit, fallback)
    }

    private func label(of step: MaestroStep) -> String? {
        switch step {
        case .tapOn(let s), .doubleTapOn(let s), .longPressOn(let s): return s.label
        case .assertVisible(let s), .assertNotVisible(let s): return s.label
        case .inputText(let s): return s.label
        default: return nil
        }
    }

    private func isOptional(_ step: MaestroStep) -> Bool {
        switch step {
        case .tapOn(let s), .doubleTapOn(let s), .longPressOn(let s): return s.optional ?? false
        case .assertVisible(let s), .assertNotVisible(let s): return s.optional ?? false
        default: return false
        }
    }
}

/// One-shot continuation latch for executor deadlines. The timed-out operation
/// may finish later if an external library ignores cancellation; its late result
/// is discarded and can never resume the caller twice.
private final class ExecutionTimeoutRace<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<T, Error>?

    init(_ continuation: CheckedContinuation<T, Error>) {
        self.continuation = continuation
    }

    func complete(_ result: Result<T, Error>) {
        lock.lock()
        guard let continuation else { lock.unlock(); return }
        self.continuation = nil
        lock.unlock()
        continuation.resume(with: result)
    }
}

actor ExecutionClipboard {
    private var value: String?
    func set(_ value: String) { self.value = value }
    func get() -> String? { value }
}
