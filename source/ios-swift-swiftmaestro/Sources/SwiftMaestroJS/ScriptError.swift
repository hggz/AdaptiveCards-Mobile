// Port of: pkg/jsengine (errors) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Errors from the embedded JavaScript engine.
public enum ScriptError: Error, CustomStringConvertible, Sendable {
    case engineUnavailable
    case evaluationFailed(String)

    public var description: String {
        switch self {
        case .engineUnavailable: return "JavaScript engine could not be created"
        case .evaluationFailed(let message): return "script error: \(message)"
        }
    }
}
