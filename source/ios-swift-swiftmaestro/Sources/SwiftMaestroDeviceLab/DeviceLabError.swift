// Port of: pkg/devicelab (errors) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Errors surfaced by the DeviceLab WebSocket transport and driver.
public enum DeviceLabError: Error, CustomStringConvertible, Sendable {
    case connectionFailed(String)
    case protocolError(String)
    case commandFailed(action: String, message: String)
    case notConnected

    public var description: String {
        switch self {
        case .connectionFailed(let s): return "DeviceLab connection failed: \(s)"
        case .protocolError(let s): return "DeviceLab protocol error: \(s)"
        case .commandFailed(let a, let m): return "DeviceLab action \(a) failed: \(m)"
        case .notConnected: return "DeviceLab not connected"
        }
    }
}
