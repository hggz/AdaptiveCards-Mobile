import XCTest
import NIOCore
import NIOPosix
import SwiftMaestroFlow
import SwiftMaestroDriver
import SwiftMaestroProcess
@testable import SwiftMaestroDeviceLab

final class DeviceLabDriverTests: XCTestCase {
    private func makeDriver(_ server: MockDeviceLabServer,
                            _ group: MultiThreadedEventLoopGroup,
                            adbRunner: MockCommandRunner) -> DeviceLabDriver {
        let client = DeviceLabClient(webSocketURL: server.webSocketURL, group: group)
        let adb = Adb(runner: adbRunner, serial: "emu-1")
        return DeviceLabDriver(adb: adb, client: client, appId: nil)
    }

    func testPlatformIsAndroid() {
        let server = MockDeviceLabServer(hierarchyJSON: "{}")
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }
        let driver = makeDriver(server, group, adbRunner: MockCommandRunner())
        XCTAssertEqual(driver.platform, .android)
    }

    func testSetUpHierarchyGesturesAndCaptureOverWebSocket() async throws {
        let server = MockDeviceLabServer(hierarchyJSON: sampleHierarchyJSON())
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let driver = makeDriver(server, group, adbRunner: MockCommandRunner())
        try await driver.setUp()

        let hierarchy = try await driver.viewHierarchy()
        XCTAssertEqual(hierarchy.platform, .android)
        let login = firstNode(in: hierarchy.root) { $0.resourceId == "com.example:id/login" }
        XCTAssertEqual(login?.text, "Login")
        XCTAssertEqual(login?.bounds, Bounds(x: 400, y: 500, width: 280, height: 90))

        try await driver.tap(Point(x: 540, y: 545))
        try await driver.inputText("hello")
        try await driver.eraseText(2)
        try await driver.swipe(from: Point(x: 10, y: 10), to: Point(x: 10, y: 300), durationMs: 200)
        try await driver.scroll(.down)
        try await driver.pressKey(.enter)
        try await driver.hideKeyboard()
        try await driver.setLocation(latitude: 1.2, longitude: 3.4)
        let screenshot = try await driver.screenshot()
        XCTAssertFalse(screenshot.isEmpty)

        try await driver.tearDown()

        let actions = server.recorder.actions
        XCTAssertEqual(actions.first, "ready")
        for expected in ["hierarchy", "tap", "inputText", "eraseText", "swipe", "scroll",
                 "pressKey", "hideKeyboard", "setLocation", "screenshot"] {
            XCTAssertTrue(actions.contains(expected), "expected action \(expected) in \(actions)")
        }
    }

    func testGestureParamsAreSent() async throws {
        let server = MockDeviceLabServer(hierarchyJSON: "{}")
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let driver = makeDriver(server, group, adbRunner: MockCommandRunner())
        try await driver.setUp()
        try await driver.tap(Point(x: 123, y: 456))
        try await driver.tearDown()

        let tapJSON = server.recorder.requests.first { $0.contains("\"action\":\"tap\"") }
        let object = try XCTUnwrap(tapJSON.flatMap {
            try? JSONSerialization.jsonObject(with: Data($0.utf8)) as? [String: Any]
        })
        let params = try XCTUnwrap(object["params"] as? [String: Any])
        XCTAssertEqual(params["x"] as? Int, 123)
        XCTAssertEqual(params["y"] as? Int, 456)
    }

    func testAppLifecycleGoesThroughAdb() async throws {
        let server = MockDeviceLabServer(hierarchyJSON: "{}")
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let adbRunner = MockCommandRunner()
        let driver = makeDriver(server, group, adbRunner: adbRunner)
        try await driver.setUp()
        try await driver.installApp("app.apk")
        try await driver.launchApp("com.example", arguments: [:])
        try await driver.stopApp("com.example")
        try await driver.clearState("com.example")
        try await driver.tearDown()

        let calls = await adbRunner.calls
        let flattened = calls.map { $0.joined(separator: " ") }
        XCTAssertTrue(flattened.contains { $0.contains("install") && $0.contains("app.apk") }, "\(flattened)")
        XCTAssertTrue(flattened.contains { $0.contains("monkey") && $0.contains("com.example") }, "\(flattened)")
        XCTAssertTrue(flattened.contains { $0.contains("force-stop") && $0.contains("com.example") }, "\(flattened)")
        XCTAssertTrue(flattened.contains { $0.contains("pm clear") || ($0.contains("pm") && $0.contains("clear")) }, "\(flattened)")
        // None of the app lifecycle should have gone over the WebSocket.
        XCTAssertFalse(server.recorder.actions.contains("launchApp"))
    }

    func testUnsupportedOperationsReportNotSupported() async throws {
        let server = MockDeviceLabServer(hierarchyJSON: "{}")
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let driver = makeDriver(server, group, adbRunner: MockCommandRunner())
        try await driver.setUp()
        do {
            try await driver.startRecording("recording.mp4")
            XCTFail("expected recording to be unsupported")
        } catch let error as DriverError {
            guard case .notSupported = error else { return XCTFail("expected .notSupported, got \(error)") }
        }
        try await driver.tearDown()
    }
}
