import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1

/// Tiny in-process WebDriverAgent HTTP mock. It serves the W3C/WDA routes used by
/// `WDAClient` and records every request, so tests never touch Xcode or a device.
final class MockWDAServer {
    struct Request: Sendable, Equatable {
        let method: String
        let uri: String
        let body: String
    }

    final class Recorder: @unchecked Sendable {
        private let lock = NSLock()
        private var storage: [Request] = []
        func append(_ request: Request) { lock.lock(); storage.append(request); lock.unlock() }
        var requests: [Request] { lock.lock(); defer { lock.unlock() }; return storage }
    }

    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var channel: Channel?
    private let sourceXML: String
    let recorder = Recorder()
    private(set) var port = 0

    init(sourceXML: String) { self.sourceXML = sourceXML }

    func start() throws -> Int {
        let sourceXML = self.sourceXML
        let recorder = self.recorder
        var bootstrap = ServerBootstrap(group: group)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(Handler(sourceXML: sourceXML, recorder: recorder))
                }
            }
        #if !os(Windows)
        bootstrap = bootstrap.serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
        #endif
        let channel = try bootstrap.bind(host: "127.0.0.1", port: 0).wait()
        self.channel = channel
        port = channel.localAddress?.port ?? 0
        return port
    }

    var baseURL: String { "http://127.0.0.1:\(port)" }

    func stop() {
        try? channel?.close().wait()
        try? group.syncShutdownGracefully()
    }

    private final class Handler: ChannelInboundHandler {
        typealias InboundIn = HTTPServerRequestPart
        typealias OutboundOut = HTTPServerResponsePart

        private let sourceXML: String
        private let recorder: Recorder
        private var head: HTTPRequestHead?
        private var body = ByteBuffer()

        init(sourceXML: String, recorder: Recorder) {
            self.sourceXML = sourceXML
            self.recorder = recorder
        }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            switch unwrapInboundIn(data) {
            case .head(let head):
                self.head = head
                body.clear()
            case .body(var bytes):
                body.writeBuffer(&bytes)
            case .end:
                guard let head else { return }
                let bodyText = body.readString(length: body.readableBytes) ?? ""
                recorder.append(Request(method: head.method.rawValue, uri: head.uri, body: bodyText))
                let response = route(method: head.method, uri: head.uri)
                respond(context: context, status: response.status, object: response.object)
                self.head = nil
            }
        }

        private func route(method: HTTPMethod, uri: String) -> (status: HTTPResponseStatus, object: Any) {
            let path = uri.split(separator: "?").first.map(String.init) ?? uri
            if method == .GET, path == "/status" {
                return (.ok, ["value": ["ready": true, "message": "mock WDA"]])
            }
            if method == .POST, path == "/session" {
                return (.ok, ["value": ["sessionId": "WDA-MOCK-SESSION"],
                              "sessionId": "WDA-MOCK-SESSION"])
            }
            if method == .DELETE, path == "/session/WDA-MOCK-SESSION" {
                return (.ok, ["value": NSNull()])
            }
            if method == .GET, path.hasSuffix("/source") {
                return (.ok, ["value": sourceXML])
            }
            if method == .GET, path.hasSuffix("/screenshot") {
                return (.ok, ["value": Data("PNGMOCK".utf8).base64EncodedString()])
            }
            if method == .POST, path.hasPrefix("/session/WDA-MOCK-SESSION/") {
                return (.ok, ["value": NSNull()])
            }
            return (.notFound, ["value": ["message": "not found: \(path)"]])
        }

        private func respond(context: ChannelHandlerContext, status: HTTPResponseStatus, object: Any) {
            let data = (try? JSONSerialization.data(withJSONObject: object)) ?? Data("{}".utf8)
            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: "application/json")
            headers.add(name: "Content-Length", value: String(data.count))
            headers.add(name: "Connection", value: "close")
            let head = HTTPResponseHead(version: .http1_1, status: status, headers: headers)
            context.write(wrapOutboundOut(.head(head)), promise: nil)
            var buffer = context.channel.allocator.buffer(capacity: data.count)
            buffer.writeBytes(data)
            context.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
            context.writeAndFlush(wrapOutboundOut(.end(nil))).whenComplete { _ in
                context.close(promise: nil)
            }
        }
    }
}
