// AsyncHTTPClientTransport — the native implementation of
// SwiftPiRelay's `RelayTransport`.
//
// This is the desktop half of the seam described in RelayTransport.swift:
// `SwiftPiRelay` knows how to shape a request and decode the response but
// deliberately owns no socket, so it can compile for
// wasm32-unknown-wasip1. Native hosts supply this transport; browser
// hosts supply a `fetch`-backed one. The provider code is identical
// either way.
//
// Lives in SwiftPiProviders because that is the target already allowed to
// link NIO and async-http-client. Nothing here may be moved into
// SwiftPiRelay.

import Foundation
import AsyncHTTPClient
import NIO
import NIOHTTP1
import SwiftPiRelay

public enum AsyncHTTPClientTransport {

    /// Build a `RelayTransport` backed by `client`.
    ///
    /// The caller owns `client` and is responsible for `shutdown()`.
    /// Response bodies are streamed through as they arrive, so the
    /// provider sees incremental SSE frames rather than one buffered
    /// blob.
    public static func make(
        client: HTTPClient,
        timeoutSeconds: Int64 = 600
    ) -> RelayTransport {
        { request in
            var httpRequest = HTTPClientRequest(url: request.url)
            httpRequest.method = .init(rawValue: request.method)
            for (name, value) in request.headers {
                httpRequest.headers.add(name: name, value: value)
            }
            if !request.body.isEmpty {
                httpRequest.body = .bytes(ByteBuffer(bytes: request.body))
            }

            let response = try await client.execute(
                httpRequest,
                timeout: .seconds(timeoutSeconds)
            )

            guard response.status == .ok else {
                // Drain a bounded amount of the error body so the caller
                // gets something actionable instead of just a status.
                var detail = ""
                var collected = 0
                for try await buffer in response.body {
                    detail += String(buffer: buffer)
                    collected += buffer.readableBytes
                    if collected > 8192 { break }
                }
                throw RelayError.httpStatus(Int(response.status.code), body: detail)
            }

            return AsyncThrowingStream { continuation in
                let task = Task {
                    do {
                        for try await buffer in response.body {
                            continuation.yield(Array(buffer.readableBytesView))
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
                continuation.onTermination = { _ in task.cancel() }
            }
        }
    }

    /// Convenience for callers that just want a provider pointed at a
    /// local relay. The returned `shutdown` closure must be awaited when
    /// the caller is done.
    public static func provider(
        endpoint: String,
        model: String,
        apiKey: String? = nil
    ) -> (provider: RelayProvider, shutdown: @Sendable () async throws -> Void) {
        let client = HTTPClient(eventLoopGroupProvider: .singleton)
        let provider = RelayProvider(
            name: "relay",
            endpoint: endpoint,
            apiKey: apiKey,
            transport: make(client: client)
        )
        return (provider, { try await client.shutdown() })
    }
}
