import XCTest
import NIOCore
import NIOPosix
@testable import SwiftMaestroBrowser

final class CDPConnectionTests: XCTestCase {
    func testConnectAndRoundTripCommand() async throws {
        let server = MockCDPServer(hierarchyJSON: "{}")
        _ = try server.start()
        defer { server.stop() }

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let connection = CDPConnection(webSocketURL: server.browserWebSocketURL, group: group)
        try await connection.connect()

        let result = try await connection.send("Browser.getVersion")
        XCTAssertEqual(result["product"] as? String, "HeadlessMock/1.0")

        await connection.close()
    }

    func testSessionRoutedCommandEchoesResult() async throws {
        let server = MockCDPServer(hierarchyJSON: "{}")
        _ = try server.start()
        defer { server.stop() }

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let connection = CDPConnection(webSocketURL: server.browserWebSocketURL, group: group)
        try await connection.connect()

        let created = try await connection.send("Target.createTarget", params: ["url": "about:blank"])
        XCTAssertEqual(created["targetId"] as? String, "MOCK-TARGET")

        let attached = try await connection.send("Target.attachToTarget",
                                                 params: ["targetId": "MOCK-TARGET", "flatten": true])
        XCTAssertEqual(attached["sessionId"] as? String, "MOCK-SESSION")

        await connection.close()
    }

    func testCommandAfterCloseThrows() async throws {
        let server = MockCDPServer(hierarchyJSON: "{}")
        _ = try server.start()
        defer { server.stop() }

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let connection = CDPConnection(webSocketURL: server.browserWebSocketURL, group: group)
        try await connection.connect()
        await connection.close()

        do {
            _ = try await connection.send("Browser.getVersion")
            XCTFail("expected send after close to throw")
        } catch {
            // Expected: notConnected.
        }
    }
}
