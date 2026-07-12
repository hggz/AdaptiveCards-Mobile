// Port of: pkg/wda (errors) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Errors surfaced by the WebDriverAgent HTTP transport and iOS host tooling.
public enum WDAError: Error, Sendable, Equatable, CustomStringConvertible {
    case invalidResponse(String)
    case requestFailed(path: String, status: UInt, message: String)
    case missingSession

    public var description: String {
        switch self {
        case .invalidResponse(let message):
            return "WDA invalid response: \(message)"
        case .requestFailed(let path, let status, let message):
            let suffix = message.isEmpty ? "" : ": \(message)"
            return "WDA request \(path) failed (HTTP \(status))\(suffix)"
        case .missingSession:
            return "WDA session not started; call setUp() first"
        }
    }
}
