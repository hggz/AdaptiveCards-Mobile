// RelayProviderTests — drives RelayProvider against a canned transport
// so the OpenAI -> StreamEvent translation is verified without a
// network, a relay process, or a model.

import XCTest
import SwiftPiCore
@testable import SwiftPiRelay

final class RelayProviderTests: XCTestCase {

    // MARK: - Helpers

    /// A transport that replays `chunks` verbatim.
    private func replaying(_ chunks: [String]) -> RelayTransport {
        { _ in
            AsyncThrowingStream { continuation in
                for chunk in chunks {
                    continuation.yield([UInt8](chunk.utf8))
                }
                continuation.finish()
            }
        }
    }

    private func collect(
        _ provider: RelayProvider,
        system: String? = nil,
        text: String = "hello"
    ) async throws -> [StreamEvent] {
        let context = Context(
            system: system,
            messages: [
                Message(id: "m1", role: .user, content: [.text(text)]),
            ],
            tools: []
        )
        let options = StreamOptions(model: "test-model", maxTokens: 64)
        var events: [StreamEvent] = []
        for try await event in provider.stream(context: context, options: options) {
            events.append(event)
        }
        return events
    }

    private func chunk(_ content: String) -> String {
        """
        data: {"id":"chatcmpl-1","model":"test-model","choices":[{"index":0,"delta":{"content":"\(content)"},"finish_reason":null}]}


        """
    }

    // MARK: - Translation

    func testTranslatesDeltasIntoAnthropicShapedEvents() async throws {
        let provider = RelayProvider(
            endpoint: "http://127.0.0.1:8099/v1/chat/completions",
            transport: replaying([
                chunk("Hello"),
                chunk(", world"),
                """
                data: {"id":"chatcmpl-1","model":"test-model","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

                data: [DONE]


                """,
            ])
        )

        let events = try await collect(provider)

        guard case .messageStart = events.first else {
            return XCTFail("expected messageStart, got \(String(describing: events.first))")
        }
        guard case .contentBlockStart(let start) = events[1] else {
            return XCTFail("expected contentBlockStart")
        }
        XCTAssertEqual(start.index, 0)

        // Reassemble the streamed text.
        var text = ""
        for event in events {
            if case .contentBlockDelta(let delta) = event,
               case .object(let object) = delta.delta,
               case .string(let piece)? = object["text"]
            {
                text += piece
            }
        }
        XCTAssertEqual(text, "Hello, world")

        guard case .messageStop = events.last else {
            return XCTFail("expected messageStop last, got \(String(describing: events.last))")
        }

        // `stop` must be normalised to Anthropic's `end_turn`.
        let stopReasons: [String] = events.compactMap { event in
            guard case .messageDelta(let payload) = event,
                  case .object(let object) = payload.delta,
                  case .string(let reason)? = object["stop_reason"]
            else { return nil }
            return reason
        }
        XCTAssertEqual(stopReasons, ["end_turn"])
    }

    /// Chunk boundaries must not be load-bearing: an SSE frame split
    /// mid-token, and a multi-byte UTF-8 sequence split across chunks,
    /// both have to reassemble.
    func testSurvivesArbitraryChunkBoundaries() async throws {
        let full = chunk("caf\u{00E9}") + """
        data: {"id":"chatcmpl-1","model":"test-model","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

        data: [DONE]


        """
        let bytes = [UInt8](full.utf8)
        let pieces = stride(from: 0, to: bytes.count, by: 7).map { start in
            Array(bytes[start..<min(start + 7, bytes.count)])
        }

        let provider = RelayProvider(
            endpoint: "http://127.0.0.1:8099/v1/chat/completions",
            transport: { _ in
                AsyncThrowingStream { continuation in
                    for piece in pieces { continuation.yield(piece) }
                    continuation.finish()
                }
            }
        )

        let events = try await collect(provider)
        var text = ""
        for event in events {
            if case .contentBlockDelta(let delta) = event,
               case .object(let object) = delta.delta,
               case .string(let piece)? = object["text"]
            {
                text += piece
            }
        }
        XCTAssertEqual(text, "caf\u{00E9}")
    }

    /// A transport that ends without a terminal frame must still produce
    /// a well-formed close, otherwise the agent loop would hang.
    func testSynthesisesTerminalEventsOnTruncatedStream() async throws {
        let provider = RelayProvider(
            endpoint: "http://127.0.0.1:8099/v1/chat/completions",
            transport: replaying([chunk("partial")])
        )

        let events = try await collect(provider)
        guard case .messageStop = events.last else {
            return XCTFail("expected synthesised messageStop")
        }
        XCTAssertTrue(events.contains { if case .contentBlockStop = $0 { return true } else { return false } })
    }

    func testSurfacesRelayErrorFrameAsErrorEvent() async throws {
        let provider = RelayProvider(
            endpoint: "http://127.0.0.1:8099/v1/chat/completions",
            transport: replaying([
                """
                data: {"error":{"message":"backend exploded"}}


                """,
            ])
        )

        let events = try await collect(provider)
        let messages: [String] = events.compactMap { event in
            guard case .error(let payload) = event else { return nil }
            return payload.message
        }
        XCTAssertEqual(messages, ["backend exploded"])
    }

    // MARK: - Request encoding

    func testEncodesSystemPromptAndHistory() throws {
        let context = Context(
            system: "be terse",
            messages: [
                Message(id: "m1", role: .user, content: [.text("hi")]),
                Message(id: "m2", role: .assistant, content: [.text("hello")]),
            ],
            tools: []
        )
        let bytes = try RelayProvider.encodeRequest(
            context: context,
            options: StreamOptions(model: "m", maxTokens: 32)
        )
        let json = String(decoding: bytes, as: UTF8.self)

        XCTAssertTrue(json.contains("\"stream\":true"), json)
        XCTAssertTrue(json.contains("be terse"), json)
        XCTAssertTrue(json.contains("\"role\":\"system\""), json)
        XCTAssertTrue(json.contains("\"role\":\"assistant\""), json)
    }

    func testDataPayloadParsing() {
        XCTAssertEqual(RelayProvider.dataPayload(of: "data: {\"a\":1}"), "{\"a\":1}")
        XCTAssertEqual(RelayProvider.dataPayload(of: "data:{\"a\":1}"), "{\"a\":1}")
        XCTAssertNil(RelayProvider.dataPayload(of: ": keep-alive comment"))
        XCTAssertNil(RelayProvider.dataPayload(of: "event: ping"))
    }
}
