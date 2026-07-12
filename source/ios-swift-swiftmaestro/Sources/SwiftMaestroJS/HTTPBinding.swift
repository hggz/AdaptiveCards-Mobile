// Port of: pkg/jsengine (http binding) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1

/// A request issued by script code via the `http` global.
public struct HTTPScriptRequest: Sendable, Equatable {
    public var method: String
    public var url: String
    public var headers: [String: String]
    public var body: String?

    public init(method: String, url: String, headers: [String: String] = [:], body: String? = nil) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }
}

/// The response returned to script code.
public struct HTTPScriptResponse: Sendable, Equatable {
    public var status: Int
    public var body: String

    public init(status: Int, body: String) {
        self.status = status
        self.body = body
    }
}

/// The `http` capability exposed to scripts. Synchronous because the JS engine is
/// synchronous; the production binding bridges to async-http-client, and tests
/// inject a fake so the suite never touches the network.
public protocol HTTPBinding: Sendable {
    func request(_ request: HTTPScriptRequest) -> HTTPScriptResponse
}

/// Production `http` binding backed by async-http-client. Bridges the engine's
/// synchronous call to NIO by waiting on the request's `EventLoopFuture` on the
/// (non-event-loop) engine thread — safe, and it never blocks a NIO loop.
public struct AsyncHTTPBinding: HTTPBinding {
    private let client: HTTPClient
    private let timeoutSeconds: Int64

    public init(client: HTTPClient = .shared, timeoutSeconds: Int64 = 30) {
        self.client = client
        self.timeoutSeconds = timeoutSeconds
    }

    public func request(_ scriptRequest: HTTPScriptRequest) -> HTTPScriptResponse {
        do {
            var request = try HTTPClient.Request(url: scriptRequest.url,
                                                 method: Self.method(scriptRequest.method))
            for (name, value) in scriptRequest.headers { request.headers.add(name: name, value: value) }
            if let body = scriptRequest.body { request.body = .string(body) }

            let response = try client.execute(request: request,
                                              deadline: .now() + .seconds(timeoutSeconds)).wait()
            var bodyString = ""
            if var buffer = response.body { bodyString = buffer.readString(length: buffer.readableBytes) ?? "" }
            return HTTPScriptResponse(status: Int(response.status.code), body: bodyString)
        } catch {
            return HTTPScriptResponse(status: -1, body: "\(error)")
        }
    }

    private static func method(_ raw: String) -> HTTPMethod {
        switch raw.uppercased() {
        case "GET": return .GET
        case "POST": return .POST
        case "PUT": return .PUT
        case "DELETE": return .DELETE
        case "PATCH": return .PATCH
        case "HEAD": return .HEAD
        case "OPTIONS": return .OPTIONS
        default: return .RAW(value: raw.uppercased())
        }
    }
}
