import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOWebSocket

/// In-process mock of the on-device DeviceLab server: upgrades to a WebSocket and
/// answers the `{id, action, params}` requests the driver sends with canned
/// `{id, result}` responses, so the driver suite runs with no real device. Every
/// request's raw JSON is recorded for assertions.
final class MockDeviceLabServer {
    private let group: MultiThreadedEventLoopGroup
    private var channel: Channel?
    private let hierarchyJSON: String
    let recorder = Recorder()
    private(set) var port: Int = 0

    init(hierarchyJSON: String) {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.hierarchyJSON = hierarchyJSON
    }

    func start() throws -> Int {
        let hierarchyJSON = self.hierarchyJSON
        let recorder = self.recorder
        var bootstrap = ServerBootstrap(group: group)
            .childChannelInitializer { channel in
                let upgrader = NIOWebSocketServerUpgrader(
                    shouldUpgrade: { channel, _ -> EventLoopFuture<HTTPHeaders?> in
                        channel.eventLoop.makeSucceededFuture(HTTPHeaders())
                    },
                    upgradePipelineHandler: { channel, _ in
                        channel.pipeline.addHandler(Handler(hierarchyJSON: hierarchyJSON, recorder: recorder))
                    }
                )
                let config: NIOHTTPServerUpgradeConfiguration = (upgraders: [upgrader], completionHandler: { _ in })
                return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: config)
            }
        #if !os(Windows)
        bootstrap = bootstrap.serverChannelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
        #endif
        let channel = try bootstrap.bind(host: "127.0.0.1", port: 0).wait()
        self.channel = channel
        self.port = channel.localAddress?.port ?? 0
        return port
    }

    func stop() {
        try? channel?.close().wait()
        try? group.syncShutdownGracefully()
    }

    var webSocketURL: String { "ws://127.0.0.1:\(port)/devicelab" }

    /// Thread-safe recorder of the raw request JSON strings the server received.
    final class Recorder: @unchecked Sendable {
        private let lock = NSLock()
        private var items: [String] = []
        func record(_ text: String) { lock.lock(); items.append(text); lock.unlock() }
        var requests: [String] { lock.lock(); defer { lock.unlock() }; return items }
        var actions: [String] {
            requests.compactMap {
                guard let data = $0.data(using: .utf8),
                      let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
                return object["action"] as? String
            }
        }
    }

    private final class Handler: ChannelInboundHandler {
        typealias InboundIn = WebSocketFrame
        typealias OutboundOut = WebSocketFrame

        private let hierarchyJSON: String
        private let recorder: Recorder

        init(hierarchyJSON: String, recorder: Recorder) {
            self.hierarchyJSON = hierarchyJSON
            self.recorder = recorder
        }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let frame = unwrapInboundIn(data)
            switch frame.opcode {
            case .text:
                var payload = frame.unmaskedData
                let text = payload.readString(length: payload.readableBytes) ?? ""
                handle(text, context: context)
            case .ping:
                let pong = WebSocketFrame(fin: true, opcode: .pong, data: frame.unmaskedData)
                context.writeAndFlush(wrapOutboundOut(pong), promise: nil)
            case .connectionClose:
                context.close(promise: nil)
            default:
                break
            }
        }

        private func handle(_ text: String, context: ChannelHandlerContext) {
            guard let data = text.data(using: .utf8),
                  let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let id = object["id"] as? Int,
                  let action = object["action"] as? String else {
                return
            }
            recorder.record(text)
            let params = object["params"] as? [String: Any] ?? [:]
            let response: [String: Any] = ["id": id, "result": cannedResult(action: action, params: params)]
            send(response, context: context)
        }

        private func cannedResult(action: String, params: [String: Any]) -> [String: Any] {
            switch action {
            case "ready":
                return ["ready": true]
            case "hierarchy":
                let node = (try? JSONSerialization.jsonObject(with: Data(hierarchyJSON.utf8))) as? [String: Any] ?? [:]
                return ["root": node]
            case "screenshot":
                return ["data": Data("PNGMOCK".utf8).base64EncodedString()]
            default:
                // tap / longPress / swipe / scroll / inputText / eraseText /
                // pressKey / hideKeyboard / setLocation
                return [:]
            }
        }

        private func send(_ object: [String: Any], context: ChannelHandlerContext) {
            guard let data = try? JSONSerialization.data(withJSONObject: object),
                  let text = String(data: data, encoding: .utf8) else { return }
            var buffer = context.channel.allocator.buffer(capacity: text.utf8.count)
            buffer.writeString(text)
            let frame = WebSocketFrame(fin: true, opcode: .text, data: buffer)
            context.writeAndFlush(wrapOutboundOut(frame), promise: nil)
        }
    }
}
