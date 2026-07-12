import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOWebSocket

/// In-process Chrome-DevTools-Protocol mock: upgrades `/devtools/...` to a
/// WebSocket and answers the CDP commands `BrowserDriver` sends with canned
/// results, so the web-driver suite runs with no real browser.
///
/// `hierarchyJSON` is the pre-encoded DOM tree returned for the driver's DOM
/// snapshot (`Runtime.evaluate` carrying the `__swiftmaestro_dom__` marker); it is
/// a `String` so nothing non-`Sendable` crosses into the channel handlers.
final class MockCDPServer {
    private let group: MultiThreadedEventLoopGroup
    private var channel: Channel?
    private let hierarchyJSON: String
    private(set) var port: Int = 0

    init(hierarchyJSON: String) {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.hierarchyJSON = hierarchyJSON
    }

    /// Bind on an ephemeral loopback port and return it.
    func start() throws -> Int {
        let hierarchyJSON = self.hierarchyJSON
        var bootstrap = ServerBootstrap(group: group)
            .childChannelInitializer { channel in
                // Build the upgrader inside the initializer so only the Sendable
                // `hierarchyJSON` String is captured across the boundary.
                let upgrader = NIOWebSocketServerUpgrader(
                    shouldUpgrade: { channel, _ -> EventLoopFuture<HTTPHeaders?> in
                        channel.eventLoop.makeSucceededFuture(HTTPHeaders())
                    },
                    upgradePipelineHandler: { channel, _ in
                        channel.pipeline.addHandler(CDPFrameHandler(hierarchyJSON: hierarchyJSON))
                    }
                )
                let config: NIOHTTPServerUpgradeConfiguration = (
                    upgraders: [upgrader],
                    completionHandler: { _ in }
                )
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

    var browserWebSocketURL: String { "ws://127.0.0.1:\(port)/devtools/browser/mock" }

    // MARK: - Frame handling

    private final class CDPFrameHandler: ChannelInboundHandler {
        typealias InboundIn = WebSocketFrame
        typealias OutboundOut = WebSocketFrame

        private let hierarchyJSON: String

        init(hierarchyJSON: String) { self.hierarchyJSON = hierarchyJSON }

        func channelRead(context: ChannelHandlerContext, data: NIOAny) {
            let frame = unwrapInboundIn(data)
            switch frame.opcode {
            case .text:
                var payload = frame.unmaskedData
                let text = payload.readString(length: payload.readableBytes) ?? ""
                handleCommand(text, context: context)
            case .ping:
                let pong = WebSocketFrame(fin: true, opcode: .pong, data: frame.unmaskedData)
                context.writeAndFlush(wrapOutboundOut(pong), promise: nil)
            case .connectionClose:
                context.close(promise: nil)
            default:
                break
            }
        }

        private func handleCommand(_ text: String, context: ChannelHandlerContext) {
            guard let data = text.data(using: .utf8),
                  let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let id = object["id"] as? Int,
                  let method = object["method"] as? String else {
                return
            }
            let params = object["params"] as? [String: Any] ?? [:]
            let result = cannedResult(method: method, params: params)
            var response: [String: Any] = ["id": id, "result": result]
            if let sessionId = object["sessionId"] as? String { response["sessionId"] = sessionId }
            send(response, context: context)
        }

        private func cannedResult(method: String, params: [String: Any]) -> [String: Any] {
            switch method {
            case "Target.createTarget":
                return ["targetId": "MOCK-TARGET"]
            case "Target.attachToTarget":
                return ["sessionId": "MOCK-SESSION"]
            case "Page.navigate":
                return ["frameId": "MOCK-FRAME"]
            case "Runtime.evaluate":
                let expression = params["expression"] as? String ?? ""
                if expression.contains("document.readyState") {
                    return ["result": ["type": "string", "value": "complete"]]
                }
                if expression.contains("__swiftmaestro_query__") {
                    return ["result": ["type": "object", "value": [
                        "x": 40, "y": 500, "width": 200, "height": 48,
                    ]]]
                }
                if expression.contains("__swiftmaestro_dom__") {
                    let node = (try? JSONSerialization.jsonObject(with: Data(hierarchyJSON.utf8))) as? [String: Any] ?? [:]
                    return ["result": ["type": "object", "value": node]]
                }
                return ["result": ["type": "undefined"]]
            case "Page.captureScreenshot":
                return ["data": Data("PNGMOCK".utf8).base64EncodedString()]
            case "Browser.getVersion":
                return ["product": "HeadlessMock/1.0", "protocolVersion": "1.3"]
            default:
                // Page.enable / Runtime.enable / DOM.enable / Network.* / Input.* /
                // Emulation.* / Target.closeTarget — acknowledged with an empty result.
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
