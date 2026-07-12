// Port of: pkg/executor (errors) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Errors raised while executing a flow step.
public enum ExecutionError: Error, Sendable, Equatable, CustomStringConvertible {
    /// A selector matched nothing in the current view hierarchy.
    case elementNotFound(String)
    /// An `assert*` step did not hold.
    case assertionFailed(String)
    /// A referenced subflow/script file was missing.
    case missingFile(String)

    public var description: String {
        switch self {
        case .elementNotFound(let selector): return "element not found: \(selector)"
        case .assertionFailed(let detail): return detail
        case .missingFile(let path): return "referenced file not found: \(path)"
        }
    }
}
