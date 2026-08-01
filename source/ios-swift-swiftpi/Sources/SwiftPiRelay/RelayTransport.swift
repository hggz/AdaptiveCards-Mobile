// RelayTransport — the seam that keeps the network stack out of the
// agent.
//
// swiftpi's Anthropic provider owns an `HTTPClient`, which transitively
// pulls NIO and BoringSSL into the build graph. Those cannot compile for
// `wasm32-unknown-wasip1` (no Berkeley sockets — BoringSSL fails on a
// missing `netdb.h`), so any target that wants to run inside a
// WebAssembly module must not link them.
//
// `RelayTransport` inverts the dependency: the provider describes *what*
// it wants sent and the host decides *how* to send it. A desktop host
// backs this with async-http-client; a browser host backs it with
// `fetch`; a test backs it with a canned byte stream. The provider code
// is identical in all three cases and depends only on Foundation.

import Foundation

/// A single outbound HTTP request, described in transport-agnostic terms.
public struct RelayRequest: Sendable, Equatable {
    public let url: String
    public let method: String
    public let headers: [String: String]
    public let body: [UInt8]

    public init(
        url: String,
        method: String = "POST",
        headers: [String: String] = [:],
        body: [UInt8] = []
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}

/// Performs `request` and yields the response body as it arrives.
///
/// Chunk boundaries are not significant: implementations may deliver the
/// body in whatever sizes the underlying transport produces, including
/// splitting a multi-byte UTF-8 sequence or an SSE frame across chunks.
/// `RelayProvider` reassembles both.
///
/// Non-2xx responses should be surfaced by throwing, not by yielding the
/// error body.
public typealias RelayTransport = @Sendable (
    _ request: RelayRequest
) async throws -> AsyncThrowingStream<[UInt8], Error>

/// Errors raised by the relay provider itself, as opposed to errors
/// raised by whatever transport it was handed.
public enum RelayError: Error, Equatable, Sendable, CustomStringConvertible {
    case httpStatus(Int, body: String)
    case malformedChunk(String)
    case emptyStream

    public var description: String {
        switch self {
        case .httpStatus(let code, let body):
            return "relay HTTP \(code): \(body)"
        case .malformedChunk(let detail):
            return "relay malformed chunk: \(detail)"
        case .emptyStream:
            return "relay produced no events"
        }
    }
}
