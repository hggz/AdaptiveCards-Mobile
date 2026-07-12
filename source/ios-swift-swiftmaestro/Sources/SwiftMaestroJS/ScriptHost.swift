// Port of: pkg/jsengine (host) + pkg/executor (${…}) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// The async, thread-safe entry point to JavaScript scripting for the executor.
///
/// A `ScriptEngine` (Duktape) is single-threaded, so every access is funneled
/// through one serial queue; the blocking work (including a synchronous `http`
/// call) runs there, off the Swift-concurrency cooperative pool. The persistent
/// `output` object and any injected variables live across the whole flow, exactly
/// as Maestro shares one JS runtime per test.
public final class ScriptHost: @unchecked Sendable {
    private let queue = DispatchQueue(label: "com.swiftmaestro.js")
    private let engine: ScriptEngine

    public init(http: HTTPBinding? = nil) throws {
        self.engine = try ScriptEngine(http: http)
    }

    /// Inject flow `env` values as JS globals (only valid identifiers).
    public func setEnvironment(_ env: [String: String]) async {
        await onQueue { engine in
            for (name, value) in env where ScriptHost.isValidIdentifier(name) {
                engine.setStringGlobal(name, value)
            }
        }
    }

    /// Evaluate a JS expression and return the typed result.
    public func evaluate(_ expression: String) async throws -> JSValue {
        try await onQueueThrowing { engine in try engine.evaluate(expression) }
    }

    /// Run a script for its side effects (e.g. populating `output`).
    @discardableResult
    public func run(_ source: String) async throws -> JSValue {
        try await onQueueThrowing { engine in try engine.run(source) }
    }

    /// Evaluate a condition's truthiness (`assertTrue`, `when: true:`).
    public func isTruthy(_ expression: String) async -> Bool {
        await onQueue { engine in ((try? engine.evaluate(expression)) ?? .undefined).isTruthy }
    }

    /// The persistent `output` object flattened to string values.
    public func output() async -> [String: String] {
        await onQueue { engine in
            guard case .object(let object) = engine.getGlobal("output") else { return [:] }
            var out: [String: String] = [:]
            for (key, value) in object { out[key] = value.stringValue }
            return out
        }
    }

    /// Expand `${…}` occurrences by evaluating each as a JS expression. An
    /// expression that is `undefined` or throws is left verbatim (`${expr}`), so a
    /// plain `${NAME}` with no such variable behaves like the pre-JS resolver.
    public func expand(_ text: String) async -> String {
        guard text.contains("${") else { return text }
        return await onQueue { engine in ScriptHost.expand(text, engine) }
    }

    // MARK: - Queue plumbing

    private func onQueue<T: Sendable>(_ body: @escaping @Sendable (ScriptEngine) -> T) async -> T {
        await withCheckedContinuation { continuation in
            queue.async { continuation.resume(returning: body(self.engine)) }
        }
    }

    private func onQueueThrowing<T: Sendable>(_ body: @escaping @Sendable (ScriptEngine) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do { continuation.resume(returning: try body(self.engine)) }
                catch { continuation.resume(throwing: error) }
            }
        }
    }

    private static func expand(_ text: String, _ engine: ScriptEngine) -> String {
        var result = ""
        var rest = Substring(text)
        while let open = rest.range(of: "${") {
            result += rest[rest.startIndex..<open.lowerBound]
            let afterOpen = rest[open.upperBound...]
            guard let close = afterOpen.range(of: "}") else {
                result += rest[open.lowerBound...]
                return result
            }
            let expression = String(afterOpen[afterOpen.startIndex..<close.lowerBound])
            let value = (try? engine.evaluate(expression)) ?? .undefined
            if case .undefined = value {
                result += "${\(expression)}"
            } else {
                result += value.stringValue
            }
            rest = afterOpen[close.upperBound...]
        }
        result += rest
        return result
    }

    private static func isValidIdentifier(_ name: String) -> Bool {
        guard let first = name.first, first.isLetter || first == "_" || first == "$" else { return false }
        return name.dropFirst().allSatisfy { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "$" }
    }
}
