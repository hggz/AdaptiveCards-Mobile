import XCTest
import NIOCore
import NIOPosix
@testable import SwiftMaestroDeviceLab

final class DeviceLabClientTests: XCTestCase {
    func testConnectAndRoundTrip() async throws {
        let server = MockDeviceLabServer(hierarchyJSON: "{}")
        _ = try server.start()
        defer { server.stop() }

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let client = DeviceLabClient(webSocketURL: server.webSocketURL, group: group)
        try await client.connect()

        let result = try await client.send("ready")
        XCTAssertEqual(result["ready"] as? Bool, true)

        await client.close()
    }

    func testSendAfterCloseThrows() async throws {
        let server = MockDeviceLabServer(hierarchyJSON: "{}")
        _ = try server.start()
        defer { server.stop() }

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let client = DeviceLabClient(webSocketURL: server.webSocketURL, group: group)
        try await client.connect()
        await client.close()

        do {
            _ = try await client.send("ready")
            XCTFail("expected send after close to throw")
        } catch {
            // expected: notConnected
        }
    }
}
