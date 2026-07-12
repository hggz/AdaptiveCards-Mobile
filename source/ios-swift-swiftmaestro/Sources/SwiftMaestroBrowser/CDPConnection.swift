// Port of: pkg/cdp (websocket transport) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import NIOCore
import NIOPosix
import WebSocketKit

/// A single Chrome DevTools Protocol connection over one WebSocket.
///
/// Correlates responses to requests by a monotonic `id`, and supports CDP "flat"
/// session routing (a `sessionId` field on each message) so one browser-level
/// socket can drive page targets — the modern, robust way to talk to a headless
/// browser. All shared state (the pending-request table, the socket) lives inside
/// the actor, so websocket-kit's non-Sendable callback surface is used safely.
public actor CDPConnection {
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
    /// fails (e.g. the CDP endpoint is not up yet).
    public func connect() async throws {
        let (scheme, host, port, path) = parseWebSocketURL(url)
        // CDP screenshot / DOM responses routinely exceed websocket-kit's 16 KiB
        // default frame size. Keep a bounded 32 MiB ceiling: large enough for a
        // high-resolution PNG, small enough to reject unbounded payloads.
        var configuration = WebSocketClient.Configuration(maxFrameSize: 32 * 1024 * 1024)
        configuration.maxAccumulatedFrameSize = 32 * 1024 * 1024
        configuration.maxAccumulatedFrameCount = 4_096
        let client = WebSocketClient(eventLoopGroupProvider: .shared(group),
                         configuration: configuration)
        self.client = client

        let ws: WebSocket = try await withCheckedThrowingContinuation { continuation in
            client.connect(scheme: scheme, host: host, port: port, path: path) { ws in
                // This closure runs on the channel event loop. websocket-kit stores
                // the text/binary callbacks in a `NIOLoopBoundBox`, so `onText` MUST
                // be assigned here, not from the actor's executor (doing so trips a
                // NIOLoopBound precondition). `send`/`close` use the thread-safe
                // `channel.writeAndFlush`, so those are fine to call off-loop later.
                ws.onText { [weak self] _, text in
                    Task { await self?.handleMessage(text) }
                }
                ws.onClose.whenComplete { [weak self] _ in
                    Task { await self?.failAllPending(CDPError.notConnected) }
                }
                continuation.resume(returning: ws)
            }.whenFailure { error in
                continuation.resume(throwing: CDPError.connectionFailed("\(error)"))
            }
        }
        self.webSocket = ws
    }

    /// Send a CDP command and await its result object. Page-domain commands pass a
    /// `sessionId` (flat mode). Throws `CDPError` on a protocol error or timeout.
    @discardableResult
    public func send(_ method: String,
                     params: [String: Any] = [:],
                     sessionId: String? = nil) async throws -> [String: Any] {
        guard let webSocket else { throw CDPError.notConnected }
        nextId += 1
        let id = nextId
        var message: [String: Any] = ["id": id, "method": method]
        if !params.isEmpty { message["params"] = params }
        if let sessionId { message["sessionId"] = sessionId }

        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let text = String(data: data, encoding: .utf8) else {
            throw CDPError.protocolError("failed to encode command \(method)")
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String: Any], Error>) in
            pending[id] = continuation
            webSocket.send(text)
            // GCD watchdog: resume with a timeout error if no response arrives.
            let timeoutMs = self.requestTimeoutMs
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(timeoutMs)) { [weak self] in
                Task { await self?.timeoutPending(id, method: method) }
            }
        }
    }

    /// Send a command without awaiting a response. For shutdown commands like
    /// `Browser.close`, where the browser exits and never replies.
    public func sendNoWait(_ method: String, params: [String: Any] = [:], sessionId: String? = nil) {
        guard let webSocket else { return }
        nextId += 1
        var message: [String: Any] = ["id": nextId, "method": method]
        if !params.isEmpty { message["params"] = params }
        if let sessionId { message["sessionId"] = sessionId }
        if let data = try? JSONSerialization.data(withJSONObject: message),
           let text = String(data: data, encoding: .utf8) {
            webSocket.send(text)
        }
    }

    /// Close the socket and fail any outstanding requests.
    public func close() async {
        let ws = webSocket
        webSocket = nil
        failAllPending(CDPError.notConnected)
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
            // An event (has `method`, no `id`). Not consumed in this phase.
            return
        }
        guard let continuation = pending.removeValue(forKey: id) else { return }
        if let error = object["error"] as? [String: Any] {
            let message = (error["message"] as? String) ?? "\(error)"
            continuation.resume(throwing: CDPError.protocolError(message))
        } else {
            continuation.resume(returning: (object["result"] as? [String: Any]) ?? [:])
        }
    }

    private func timeoutPending(_ id: Int, method: String) {
        guard let continuation = pending.removeValue(forKey: id) else { return }
        continuation.resume(throwing: CDPError.commandFailed(method: method,
                                                             message: "timed out after \(requestTimeoutMs)ms"))
    }

    private func failAllPending(_ error: Error) {
        let outstanding = pending
        pending = [:]
        for (_, continuation) in outstanding { continuation.resume(throwing: error) }
    }
}
