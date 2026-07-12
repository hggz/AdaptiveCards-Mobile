import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1

/// In-process Appium 2/3 W3C hub mock. It records requests and can deliberately
/// fail session creation with a supplied message for credential-redaction tests.
final class MockAppiumServer {
    struct Request: Sendable, Equatable {
        let method: String
        let uri: String
        let headers: [String: String]
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
    private let sessionError: String?
    let recorder = Recorder()
    private(set) var port = 0

    init(sourceXML: String, sessionError: String? = nil) {
        self.sourceXML = sourceXML
        self.sessionError = sessionError
    }

    func start() throws -> Int {
        let sourceXML = self.sourceXML
        let sessionError = self.sessionError
        let recorder = self.recorder
        var bootstrap = ServerBootstrap(group: group)
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline().flatMap {
                    channel.pipeline.addHandler(Handler(sourceXML: sourceXML,
                                                        sessionError: sessionError,
                                                        recorder: recorder))
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
        private let sessionError: String?
        private let recorder: Recorder
        private var requestHead: HTTPRequestHead?
        private var requestBody = ByteBuffer()

        init(sourceXML: String, sessionError: String?, recorder: Recorder) {
            self.sourceXML = sourceXML
            self.sessionError = sessionError
            self.recorder = recorder
        }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            switch unwrapInboundIn(data) {
            case .head(let head):
                requestHead = head
                requestBody.clear()
            case .body(var body):
                requestBody.writeBuffer(&body)
            case .end:
                guard let head = requestHead else { return }
                let body = requestBody.readString(length: requestBody.readableBytes) ?? ""
                recorder.append(Request(method: head.method.rawValue,
                                        uri: head.uri,
                                        headers: Dictionary(uniqueKeysWithValues:
                                            head.headers.map { ($0.name.lowercased(), $0.value) }),
                                        body: body))
                let response = route(method: head.method, uri: head.uri)
                respond(context: context, status: response.status, object: response.object)
                requestHead = nil
            }
        }

        private func route(method: HTTPMethod, uri: String) -> (status: HTTPResponseStatus, object: Any) {
            let path = uri.split(separator: "?").first.map(String.init) ?? uri
            if method == .GET, path.hasSuffix("/status") {
                return (.ok, ["value": ["ready": true]])
            }
            if method == .POST, path.hasSuffix("/session"), !path.contains("/session/") {
                if let sessionError {
                    return (.internalServerError,
                            ["value": ["error": "session not created", "message": sessionError]])
                }
                return (.ok, ["value": ["sessionId": "APPIUM-MOCK-SESSION",
                                         "capabilities": ["mock": true]],
                              "sessionId": "APPIUM-MOCK-SESSION"])
            }
            if method == .DELETE, path.hasSuffix("/session/APPIUM-MOCK-SESSION") {
                return (.ok, ["value": NSNull()])
            }
            if method == .GET, path.hasSuffix("/source") {
                return (.ok, ["value": sourceXML])
            }
            if method == .GET, path.hasSuffix("/screenshot") {
                return (.ok, ["value": Data("PNGMOCK".utf8).base64EncodedString()])
            }
            if method == .POST, path.hasSuffix("/appium/stop_recording_screen") {
                return (.ok, ["value": Data("MP4MOCK".utf8).base64EncodedString()])
            }
            if method == .POST, path.contains("/session/APPIUM-MOCK-SESSION/") {
                return (.ok, ["value": NSNull()])
            }
            return (.notFound, ["value": ["error": "unknown command", "message": "not found: \(path)"]])
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
