// Port of: pkg/devicelab (websocket transport) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import NIOCore
import NIOPosix
import WebSocketKit

/// A single persistent connection to the on-device DeviceLab server, spoken as a
/// request/response JSON protocol over one WebSocket:
///
///     -> { "id": N, "action": "<name>", "params": { … } }
///     <- { "id": N, "result": { … } }   |   { "id": N, "error": "<message>" }
///
/// Responses are correlated to requests by a monotonic `id`. All shared state
/// (the pending-request table, the socket) lives inside the actor, so
/// websocket-kit's non-Sendable callback surface is used safely. The on-device
/// server is a prebuilt artifact swiftmaestro connects to; it is not part of this
/// port (see docs/PROVENANCE.md).
public actor DeviceLabClient {
    private let url: String
    private let group: EventLoopGroup
    private let requestTimeoutMs: Int

    private var client: WebSocketClient?
    private var webSocket: WebSocket?
    private var nextId = 0
    private var pending: [Int: CheckedContinuation<[String: Any], Error>] = [:]

    public init(webSocketURL: String, group: EventLoopGroup, requestTimeoutMs: Int = 15_000) {
        self.url = webSocketURL
        self.group = group
        self.requestTimeoutMs = requestTimeoutMs
    }

    /// Open the WebSocket and wire up the message pump. Throws if the handshake
    /// fails (e.g. the DeviceLab server is not up / not adb-forwarded yet).
    public func connect() async throws {
        let (scheme, host, port, path) = Self.parseWebSocketURL(url)
        // Hierarchy and base64 screenshot responses can exceed the library's
        // 16 KiB default; use the same bounded ceiling as the CDP transport.
        var configuration = WebSocketClient.Configuration(maxFrameSize: 32 * 1024 * 1024)
        configuration.maxAccumulatedFrameSize = 32 * 1024 * 1024
        configuration.maxAccumulatedFrameCount = 4_096
        let client = WebSocketClient(eventLoopGroupProvider: .shared(group),
                         configuration: configuration)
        self.client = client

        let ws: WebSocket = try await withCheckedThrowingContinuation { continuation in
            client.connect(scheme: scheme, host: host, port: port, path: path) { ws in
                // On the channel event loop: websocket-kit stores onText in a
                // NIOLoopBoundBox, so it must be assigned here, not off the loop.
                ws.onText { [weak self] _, text in
                    Task { await self?.handleMessage(text) }
                }
                ws.onClose.whenComplete { [weak self] _ in
                    Task { await self?.failAllPending(DeviceLabError.notConnected) }
                }
                continuation.resume(returning: ws)
            }.whenFailure { error in
                continuation.resume(throwing: DeviceLabError.connectionFailed("\(error)"))
            }
        }
        self.webSocket = ws
    }

    /// Send an action and await its `result` object. Throws on a protocol error or
    /// timeout.
    @discardableResult
    public func send(_ action: String, params: [String: Any] = [:]) async throws -> [String: Any] {
        guard let webSocket else { throw DeviceLabError.notConnected }
        nextId += 1
        let id = nextId
        var message: [String: Any] = ["id": id, "action": action]
        if !params.isEmpty { message["params"] = params }

        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let text = String(data: data, encoding: .utf8) else {
            throw DeviceLabError.protocolError("failed to encode action \(action)")
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String: Any], Error>) in
            pending[id] = continuation
            webSocket.send(text)
            let timeoutMs = self.requestTimeoutMs
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(timeoutMs)) { [weak self] in
                Task { await self?.timeoutPending(id, action: action) }
            }
        }
    }

    /// Close the socket and fail any outstanding requests.
    public func close() async {
        let ws = webSocket
        webSocket = nil
        failAllPending(DeviceLabError.notConnected)
        if let ws { _ = try? await ws.close().get() }
        try? client?.syncShutdown()   // no-op for a `.shared` group
        client = nil
    }

    // MARK: - Message pump (actor-isolated)

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let object = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            return
        }
        guard let id = object["id"] as? Int else {
            return // an event (no id); not consumed in this phase
        }
        guard let continuation = pending.removeValue(forKey: id) else { return }
        if let message = object["error"] as? String {
            continuation.resume(throwing: DeviceLabError.protocolError(message))
        } else if let error = object["error"] as? [String: Any] {
            continuation.resume(throwing: DeviceLabError.protocolError((error["message"] as? String) ?? "\(error)"))
        } else {
            continuation.resume(returning: (object["result"] as? [String: Any]) ?? [:])
        }
    }

    private func timeoutPending(_ id: Int, action: String) {
        guard let continuation = pending.removeValue(forKey: id) else { return }
        continuation.resume(throwing: DeviceLabError.commandFailed(action: action,
                                                                   message: "timed out after \(requestTimeoutMs)ms"))
    }

    private func failAllPending(_ error: Error) {
        let outstanding = pending
        pending = [:]
        for (_, continuation) in outstanding { continuation.resume(throwing: error) }
    }

    /// Split a `ws://host:port/path` URL into the parts `WebSocketClient.connect`
    /// takes, falling back to loopback defaults.
    static func parseWebSocketURL(_ url: String) -> (scheme: String, host: String, port: Int, path: String) {
        guard let components = URLComponents(string: url) else {
            return ("ws", "127.0.0.1", 9008, "/")
        }
        let scheme = components.scheme ?? "ws"
        let host = components.host ?? "127.0.0.1"
        let port = components.port ?? (scheme == "wss" ? 443 : 80)
        var path = components.percentEncodedPath.isEmpty ? "/" : components.percentEncodedPath
        if let query = components.percentEncodedQuery { path += "?" + query }
        return (scheme, host, port, path)
    }
}
