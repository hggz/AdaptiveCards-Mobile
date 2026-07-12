import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1
import SwiftMaestroJS

/// A fake `http` binding: records requests and returns a fixed response, so
/// script-side HTTP is tested without any network.
final class FakeHTTPBinding: HTTPBinding, @unchecked Sendable {
    private let response: HTTPScriptResponse
    private let lock = NSLock()
    private var recorded: [HTTPScriptRequest] = []

    init(response: HTTPScriptResponse) { self.response = response }

    var requests: [HTTPScriptRequest] {
        lock.lock(); defer { lock.unlock() }
        return recorded
    }

    func request(_ request: HTTPScriptRequest) -> HTTPScriptResponse {
        lock.lock(); recorded.append(request); lock.unlock()
        return response
    }
}

/// A tiny in-process HTTP server that replies to any request with `200` and a
/// fixed JSON body, so the real `AsyncHTTPBinding` can be exercised over loopback
/// (no external network).
final class MockHTTPServer {
    private let group: MultiThreadedEventLoopGroup
    private var channel: Channel?
    private let responseJSON: String

    init(responseJSON: String) {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.responseJSON = responseJSON
    }

    func start() throws -> Int {
        let json = responseJSON
        var bootstrap = ServerBootstrap(group: group)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(Handler(json: json))
                }
            }
        #if !os(Windows)
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

        private let json: String
        init(json: String) { self.json = json }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            guard case .end = unwrapInboundIn(data) else { return }
            let body = Data(json.utf8)
            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: "application/json")
            headers.add(name: "Content-Length", value: String(body.count))
            headers.add(name: "Connection", value: "close")
            let head = HTTPResponseHead(version: .http1_1, status: .ok, headers: headers)
            context.write(wrapOutboundOut(.head(head)), promise: nil)
            var buffer = context.channel.allocator.buffer(capacity: body.count)
            buffer.writeBytes(body)
            context.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
            context.writeAndFlush(wrapOutboundOut(.end(nil))).whenComplete { _ in
                context.close(promise: nil)
            }
        }
    }
}
