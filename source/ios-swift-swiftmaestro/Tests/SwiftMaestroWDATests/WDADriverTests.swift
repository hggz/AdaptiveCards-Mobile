import XCTest
import SwiftMaestroFlow
import SwiftMaestroDriver
@testable import SwiftMaestroWDA

final class WDADriverTests: XCTestCase {
    func testPlatformIsIOS() {
        let driver = WDADriver(client: WDAClient(baseURL: "http://127.0.0.1:1"),
                               startupAttempts: 1, startupIntervalMs: 0)
        XCTAssertEqual(driver.platform, .ios)
    }

    func testDriverRoutesThroughMockWDAAndHostTooling() async throws {
        let server = MockWDAServer(sourceXML: try wdaFixture())
        _ = try server.start()
        defer { server.stop() }

        let tooling = MockWDAHostTooling()
        let driver = WDADriver(client: WDAClient(baseURL: server.baseURL),
                               tooling: tooling, bundleId: "com.example",
                               startupAttempts: 1, startupIntervalMs: 0)

        try await driver.setUp()
        try await driver.installApp("Example.app")
        try await driver.launchApp("com.example", arguments: ["MODE": "test"])

        let hierarchy = try await driver.viewHierarchy()
        XCTAssertEqual(hierarchy.platform, .ios)
        XCTAssertEqual(hierarchy.root.children.first?.children.last?.accessibilityId, "loginButton")

        try await driver.tap(Point(x: 195, y: 424))
        try await driver.longPress(Point(x: 195, y: 424))
        try await driver.inputText("hello")
        try await driver.eraseText(2)
        try await driver.swipe(from: Point(x: 10, y: 100), to: Point(x: 10, y: 20), durationMs: 300)
        try await driver.scroll(.down)
        try await driver.pressKey(.home)
        try await driver.pressKey(.enter)
        try await driver.hideKeyboard()
        try await driver.clearKeychain()
        try await driver.setLocation(latitude: 1.2, longitude: 3.4)
        try await driver.addMedia(["photo.png"])
        try await driver.openLink("https://example.test")
        let screenshot = try await driver.screenshot()
        XCTAssertFalse(screenshot.isEmpty)
        try await driver.stopApp("com.example")
        try await driver.tearDown()

        let hostActions = await tooling.actions
        XCTAssertEqual(hostActions, ["prepare", "install(Example.app)",
                         "addMedia(photo.png)", "tearDown"])

        let paths = server.recorder.requests.map(\.uri)
        for suffix in [
            "/source", "/wda/tap/0", "/wda/touchAndHold", "/wda/keys",
            "/wda/dragfromtoforduration", "/wda/scroll", "/wda/pressButton",
            "/wda/keyboard/dismiss", "/wda/apps/clearKeychains", "/location",
            "/url", "/screenshot", "/wda/apps/launch", "/wda/apps/terminate",
        ] {
            XCTAssertTrue(paths.contains { $0.hasSuffix(suffix) }, "missing WDA path \(suffix) in \(paths)")
        }
    }

    func testViewHierarchyRequiresSession() async throws {
        let driver = WDADriver(client: WDAClient(baseURL: "http://127.0.0.1:1"),
                               startupAttempts: 1, startupIntervalMs: 0)
        do {
            _ = try await driver.viewHierarchy()
            XCTFail("expected missing-session error")
        } catch let error as WDAError {
            XCTAssertEqual(error, .missingSession)
        }
    }

    func testDeferredOperationsReportNotSupported() async throws {
        let driver = WDADriver(client: WDAClient(baseURL: "http://127.0.0.1:1"),
                               startupAttempts: 1, startupIntervalMs: 0)
        do {
            try await driver.clearState("com.example")
            XCTFail("expected clearState to be unsupported")
        } catch let error as DriverError {
            guard case .notSupported = error else {
                return XCTFail("expected .notSupported, got \(error)")
            }
        }
    }

    func testHostToolingHasClearNonMacOSRuntimeGate() async throws {
        #if os(macOS)
        throw XCTSkip("runtime-gate assertion is for non-macOS hosts")
        #else
        let tooling = XcodeWDAHostTooling(configuration: .init())
        do {
            try await tooling.prepare()
            XCTFail("expected a non-macOS runtime gate")
        } catch let error as DriverError {
            guard case .notSupported(let message) = error else {
                return XCTFail("expected .notSupported, got \(error)")
            }
            XCTAssertEqual(message, "iOS testing requires macOS (xcrun/simctl/Xcode).")
        }
        #endif
    }
}
