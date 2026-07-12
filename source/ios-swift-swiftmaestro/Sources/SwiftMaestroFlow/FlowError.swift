// Port of: error types across pkg/flow + pkg/validator
// (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Errors raised while parsing a Maestro flow file into the typed model.
public enum FlowParseError: Error, Sendable, Equatable, CustomStringConvertible {
    /// The document contained no steps and no configuration.
    case emptyFlow
    /// The YAML itself could not be decoded.
    case malformedYAML(String)
    /// The top-level shape was not `<config>? --- <steps>`.
    case invalidStructure(String)
    /// A step referenced a command swiftmaestro does not recognize.
    case unknownCommand(String)
    /// A recognized command was given arguments of the wrong shape.
    case invalidStep(command: String, reason: String)
    /// A selector value was neither a string nor a valid selector map.
    case invalidSelector(String)

    public var description: String {
        switch self {
        case .emptyFlow:
            return "flow is empty: no configuration or steps found"
        case .malformedYAML(let detail):
            return "malformed YAML: \(detail)"
        case .invalidStructure(let detail):
            return "invalid flow structure: \(detail)"
        case .unknownCommand(let name):
            return "unknown command: \(name)"
        case .invalidStep(let command, let reason):
            return "invalid '\(command)' step: \(reason)"
        case .invalidSelector(let detail):
            return "invalid selector: \(detail)"
        }
    }
}
