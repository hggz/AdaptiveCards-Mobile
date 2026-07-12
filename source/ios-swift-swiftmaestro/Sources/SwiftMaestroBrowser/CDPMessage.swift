// Port of: pkg/cdp (protocol support) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// Errors surfaced by the Chrome DevTools Protocol transport and web driver.
public enum CDPError: Error, CustomStringConvertible, Sendable {
    case connectionFailed(String)
    case protocolError(String)
    case commandFailed(method: String, message: String)
    case notConnected

    public var description: String {
        switch self {
        case .connectionFailed(let s): return "CDP connection failed: \(s)"
        case .protocolError(let s): return "CDP protocol error: \(s)"
        case .commandFailed(let m, let msg): return "CDP command \(m) failed: \(msg)"
        case .notConnected: return "CDP not connected"
        }
    }
}

/// A GCD-scheduled async sleep. Swift Concurrency's cooperative pool can be
/// starved by Foundation's process monitor on Windows, so browser-driver waits go
/// through GCD `asyncAfter` (see /memories/swift-foundation-process-windows.md).
func cdpNap(ms: Int) async {
    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(ms)) {
            continuation.resume()
        }
    }
}

/// Split a `ws://host:port/path?query` URL into the parts `WebSocketClient.connect`
/// takes. Falls back to loopback defaults if the URL is unparseable.
func parseWebSocketURL(_ url: String) -> (scheme: String, host: String, port: Int, path: String) {
    guard let components = URLComponents(string: url) else {
        return ("ws", "127.0.0.1", 9222, "/")
    }
    let scheme = components.scheme ?? "ws"
    let host = components.host ?? "127.0.0.1"
    let port = components.port ?? (scheme == "wss" ? 443 : 80)
    var path = components.percentEncodedPath.isEmpty ? "/" : components.percentEncodedPath
    if let query = components.percentEncodedQuery { path += "?" + query }
    return (scheme, host, port, path)
}
