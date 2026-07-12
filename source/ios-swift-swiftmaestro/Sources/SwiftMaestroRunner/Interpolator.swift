// Port of: pkg/executor (`${…}` interpolation) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Resolves `${NAME}` references against the flow `env` (then the process
/// environment). Full JavaScript-expression interpolation (`${output.x}`,
/// `${count == 3}`) arrives with the embedded JS engine in a later phase; any
/// reference that does not resolve to an env value is left verbatim so a later
/// pass can evaluate it.
public struct Interpolator: Sendable {
    public let env: [String: String]

    public init(env: [String: String]) { self.env = env }

    public func expand(_ text: String) -> String {
        guard text.contains("${") else { return text }
        var result = ""
        var rest = Substring(text)
        while let open = rest.range(of: "${") {
            result += rest[rest.startIndex..<open.lowerBound]
            let afterOpen = rest[open.upperBound...]
            guard let close = afterOpen.range(of: "}") else {
                result += rest[open.lowerBound...]
                return result
            }
            let name = afterOpen[afterOpen.startIndex..<close.lowerBound]
                .trimmingCharacters(in: .whitespaces)
            if let value = value(for: name) {
                result += value
            } else {
                result += "${\(name)}"
            }
            rest = afterOpen[close.upperBound...]
        }
        result += rest
        return result
    }

    private func value(for name: String) -> String? {
        if let v = env[name] { return v }
        if let v = ProcessInfo.processInfo.environment[name] { return v }
        return nil
    }
}
