import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1

/// A tiny in-process HTTP mock of the on-device UIAutomator2 server so driver
/// tests never touch a real device. Serves the small W3C subset the client uses:
/// `GET /status`, `POST /session`, `GET /session/:id/source` (returns the given
/// XML), and `DELETE /session/:id`.
final class MockUIA2Server {
    private let group: MultiThreadedEventLoopGroup
    private var channel: Channel?
    private let sourceXML: String

    init(sourceXML: String) {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.sourceXML = sourceXML
    }

    /// Bind on an ephemeral loopback port and return it.
    func start() throws -> Int {
        let xml = sourceXML
        var bootstrap = ServerBootstrap(group: group)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(Handler(sourceXML: xml))
                }
            }
        #if !os(Windows)
        // ChannelOptions.socket(...) is unavailable on the Windows NIO fork; the
        // reuseaddr tweak is a POSIX-only convenience.
        bootstrap = bootstrap.serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
        #endif
        let channel = try bootstrap.bind(host: "127.0.0.1", port: 0).wait()
        self.channel = channel
        return channel.localAddress?.port ?? 0
    }

    func stop() {
        try? channel?.close().wait()
        try? group.syncShutdownGracefully()
    }

    private final class Handler: ChannelInboundHandler {
        typealias InboundIn = HTTPServerRequestPart
        typealias OutboundOut = HTTPServerResponsePart

        private let sourceXML: String
        private var requestHead: HTTPRequestHead?

        init(sourceXML: String) { self.sourceXML = sourceXML }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            switch unwrapInboundIn(data) {
            case .head(let head):
                requestHead = head
            case .body:
                break
            case .end:
                guard let head = requestHead else { return }
                let (status, body) = route(method: head.method, uri: head.uri)
                respond(context: context, status: status, jsonBody: body)
            }
        }

        private func route(method: HTTPMethod, uri: String) -> (HTTPResponseStatus, Data) {
            func json(_ object: Any) -> Data {
                (try? JSONSerialization.data(withJSONObject: object)) ?? Data("{}".utf8)
            }
            let path = uri.split(separator: "?").first.map(String.init) ?? uri
            if method == .GET, path == "/status" {
                return (.ok, json(["value": ["ready": true]]))
            }
            if method == .POST, path == "/session" {
                return (.ok, json(["sessionId": "mock-session", "value": ["sessionId": "mock-session"]]))
            }
            if method == .GET, path.hasSuffix("/source") {
                return (.ok, json(["value": sourceXML]))
            }
            if method == .POST, path.hasSuffix("/keys") {
                return (.ok, json(["value": NSNull()]))
            }
            if method == .DELETE, path.hasPrefix("/session/") {
                return (.ok, json(["value": NSNull()]))
            }
            return (.notFound, json(["error": "not found: \(path)"]))
        }

        private func respond(context: ChannelHandlerContext, status: HTTPResponseStatus, jsonBody: Data) {
            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: "application/json")
            headers.add(name: "Content-Length", value: String(jsonBody.count))
            headers.add(name: "Connection", value: "close")
            let head = HTTPResponseHead(version: .http1_1, status: status, headers: headers)
            context.write(wrapOutboundOut(.head(head)), promise: nil)
            var buffer = context.channel.allocator.buffer(capacity: jsonBody.count)
            buffer.writeBytes(jsonBody)
            context.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
            context.writeAndFlush(wrapOutboundOut(.end(nil))).whenComplete { _ in
                context.close(promise: nil)
            }
        }
    }
}
