// RelayProvider — a Provider that speaks the OpenAI-compatible
// `/v1/chat/completions` streaming wire format through an injected
// transport.
//
// Why OpenAI-compatible rather than Anthropic-native: every backend we
// care about (a local relay wrapping the Copilot CLI, Ollama, llama.cpp's
// server, or a hosted gateway) either speaks this shape natively or is a
// thin adapter away from it. The agent loop never sees the difference
// because this provider translates the wire events into the same
// `StreamEvent` values `AnthropicProvider` produces.
//
// Mapping, given a stream of `chat.completion.chunk` objects:
//
//   first chunk            -> .messageStart
//   first content delta    -> .contentBlockStart(index: 0, text block)
//   each content delta     -> .contentBlockDelta(text_delta)
//   finish_reason present  -> .contentBlockStop + .messageDelta + .messageStop
//   `data: [DONE]`         -> terminates the stream
//
// This target links nothing outside Foundation and its two sibling
// targets, so it builds for wasm32-unknown-wasip1.

import Foundation
import SwiftPiCore
import SwiftPiStreaming

public struct RelayProvider: Provider {
    public let name: String
    public let endpoint: String
    public let apiKey: String?
    private let transport: RelayTransport

    /// - Parameters:
    ///   - endpoint: full URL of the completions endpoint, e.g.
    ///     `http://127.0.0.1:8099/v1/chat/completions`.
    ///   - apiKey: sent as `Authorization: Bearer ...` when non-nil. A
    ///     loopback relay typically needs none.
    ///   - transport: performs the request. See `RelayTransport`.
    public init(
        name: String = "relay",
        endpoint: String,
        apiKey: String? = nil,
        transport: @escaping RelayTransport
    ) {
        self.name = name
        self.endpoint = endpoint
        self.apiKey = apiKey
        self.transport = transport
    }

    // MARK: - Provider

    public func stream(
        context: Context,
        options: StreamOptions
    ) -> AsyncThrowingStream<StreamEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await drive(
                        context: context,
                        options: options,
                        continuation: continuation
                    )
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private func drive(
        context: Context,
        options: StreamOptions,
        continuation: AsyncThrowingStream<StreamEvent, Error>.Continuation
    ) async throws {
        var headers = [
            "content-type": "application/json",
            "accept": "text/event-stream",
        ]
        if let apiKey, !apiKey.isEmpty {
            headers["authorization"] = "Bearer \(apiKey)"
        }

        let body = try Self.encodeRequest(context: context, options: options)
        let request = RelayRequest(url: endpoint, headers: headers, body: body)

        var splitter = SSELineSplitter()
        var state = TranslationState()

        for try await chunk in try await transport(request) {
            if Task.isCancelled { break }
            for line in splitter.feed(chunk) {
                guard let payload = Self.dataPayload(of: line) else { continue }
                if payload == "[DONE]" {
                    state.finish(into: continuation)
                    continuation.finish()
                    return
                }
                try state.ingest(payload, into: continuation)
            }
        }

        state.finish(into: continuation)
        continuation.finish()
    }

    /// Extracts the value of an SSE `data:` field, or nil for comments,
    /// blank separators, and other field names.
    static func dataPayload(of line: String) -> String? {
        guard line.hasPrefix("data:") else { return nil }
        let value = line.dropFirst(5)
        return value.hasPrefix(" ") ? String(value.dropFirst()) : String(value)
    }

    // MARK: - Request encoding

    /// Builds the OpenAI-compatible request body. Assistant tool calls
    /// and tool results are flattened into text, because the relay
    /// backends we target do not all implement the tool-call wire shape;
    /// the agent's own tool loop is unaffected since it operates on
    /// `AgentEvent`s, not on this encoding.
    static func encodeRequest(
        context: Context,
        options: StreamOptions
    ) throws -> [UInt8] {
        var messages: [JSONValue] = []

        if let system = context.system, !system.isEmpty {
            messages.append(.object([
                "role": .string("system"),
                "content": .string(system),
            ]))
        }

        for message in context.messages {
            let role: String
            switch message.role {
            case .user: role = "user"
            case .assistant: role = "assistant"
            case .system: role = "system"
            }
            let text = flatten(message.content)
            guard !text.isEmpty else { continue }
            messages.append(.object([
                "role": .string(role),
                "content": .string(text),
            ]))
        }

        var payload: [String: JSONValue] = [
            "model": .string(options.model),
            "stream": .bool(true),
            "messages": .array(messages),
        ]
        if options.maxTokens > 0 {
            payload["max_tokens"] = .int(options.maxTokens)
        }

        let data = try JSONEncoder().encode(JSONValue.object(payload))
        return [UInt8](data)
    }

    static func flatten(_ blocks: [Content]) -> String {
        var pieces: [String] = []
        for block in blocks {
            switch block {
            case .text(let text):
                pieces.append(text)
            case .thinking(let text, _):
                pieces.append(text)
            case .toolUse(_, let name, let input):
                let encoded = (try? JSONEncoder().encode(input))
                    .map { String(decoding: $0, as: UTF8.self) } ?? "{}"
                pieces.append("[tool_use \(name) \(encoded)]")
            case .toolResult(_, let content, let isError):
                let label = isError ? "tool_error" : "tool_result"
                pieces.append("[\(label) \(flatten(content))]")
            case .image:
                pieces.append("[image]")
            }
        }
        return pieces.joined(separator: "\n")
    }
}

// MARK: - Wire translation

/// Tracks the small amount of state needed to turn a flat sequence of
/// OpenAI chunks into Anthropic-shaped block events.
private struct TranslationState {
    private var startedMessage = false
    private var openedBlock = false
    private var closed = false

    mutating func ingest(
        _ payload: String,
        into continuation: AsyncThrowingStream<StreamEvent, Error>.Continuation
    ) throws {
        guard let data = payload.data(using: .utf8) else {
            throw RelayError.malformedChunk("non-UTF8 payload")
        }
        let value: JSONValue
        do {
            value = try JSONDecoder().decode(JSONValue.self, from: data)
        } catch {
            throw RelayError.malformedChunk("undecodable JSON: \(error)")
        }
        guard case .object(let root) = value else {
            throw RelayError.malformedChunk("chunk was not an object")
        }

        // A relay reports backend failure as a terminal error frame.
        if case .object(let errorObject)? = root["error"] {
            let message: String
            if case .string(let text)? = errorObject["message"] {
                message = text
            } else {
                message = "unknown relay error"
            }
            continuation.yield(.error(StreamErrorPayload(
                type: "relay_error",
                message: message
            )))
            closed = true
            return
        }

        if !startedMessage {
            startedMessage = true
            continuation.yield(.messageStart(MessageStartPayload(
                message: .object([
                    "id": root["id"] ?? .string("relay"),
                    "type": .string("message"),
                    "role": .string("assistant"),
                    "model": root["model"] ?? .string("relay"),
                    "content": .array([]),
                ])
            )))
        }

        guard case .array(let choices)? = root["choices"],
              case .object(let choice)? = choices.first
        else { return }

        if case .object(let delta)? = choice["delta"],
           case .string(let text)? = delta["content"],
           !text.isEmpty
        {
            if !openedBlock {
                openedBlock = true
                continuation.yield(.contentBlockStart(ContentBlockStartPayload(
                    index: 0,
                    contentBlock: .object([
                        "type": .string("text"),
                        "text": .string(""),
                    ])
                )))
            }
            continuation.yield(.contentBlockDelta(ContentBlockDeltaPayload(
                index: 0,
                delta: .object([
                    "type": .string("text_delta"),
                    "text": .string(text),
                ])
            )))
        }

        if case .string(let reason)? = choice["finish_reason"] {
            emitTerminal(stopReason: reason, into: continuation)
        }
    }

    /// Called when the transport ends without an explicit terminal frame.
    mutating func finish(
        into continuation: AsyncThrowingStream<StreamEvent, Error>.Continuation
    ) {
        guard !closed else { return }
        emitTerminal(stopReason: "end_turn", into: continuation)
    }

    private mutating func emitTerminal(
        stopReason: String,
        into continuation: AsyncThrowingStream<StreamEvent, Error>.Continuation
    ) {
        guard !closed else { return }
        closed = true
        if openedBlock {
            continuation.yield(.contentBlockStop(ContentBlockStopPayload(index: 0)))
        }
        // OpenAI's "stop" is Anthropic's "end_turn"; anything else is
        // passed through so the agent can reason about truncation.
        let mapped = stopReason == "stop" ? "end_turn" : stopReason
        continuation.yield(.messageDelta(MessageDeltaPayload(
            delta: .object(["stop_reason": .string(mapped)]),
            usage: nil
        )))
        continuation.yield(.messageStop)
    }
}
