import XCTest
import NIOCore
import NIOPosix
import SwiftMaestroFlow
import SwiftMaestroDriver
@testable import SwiftMaestroBrowser

final class BrowserDriverTests: XCTestCase {
    /// A small canned DOM the mock returns for the driver's snapshot request.
    private func sampleHierarchyJSON() -> String {
        let button: [String: Any] = [
            "tag": "button",
            "resourceId": "login",
            "text": "Login",
            "clickable": true,
            "visible": true,
            "bounds": ["x": 40, "y": 500, "width": 200, "height": 48],
            "children": [],
        ]
        let body: [String: Any] = [
            "tag": "body",
            "visible": true,
            "bounds": ["x": 0, "y": 0, "width": 1280, "height": 800],
            "children": [button],
        ]
        let root: [String: Any] = [
            "tag": "html",
            "visible": true,
            "bounds": ["x": 0, "y": 0, "width": 1280, "height": 800],
            "children": [body],
        ]
        return jsonString(root)
    }

    private func makeDriver(_ server: MockCDPServer, _ group: MultiThreadedEventLoopGroup) -> BrowserDriver {
        BrowserDriver(endpoint: .attach(browserWebSocketURL: server.browserWebSocketURL), group: group)
    }

    func testPlatformIsWeb() {
        let server = MockCDPServer(hierarchyJSON: "{}")
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }
        let driver = makeDriver(server, group)
        XCTAssertEqual(driver.platform, .web)
    }

    func testSetUpAndViewHierarchy() async throws {
        let server = MockCDPServer(hierarchyJSON: sampleHierarchyJSON())
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let driver = makeDriver(server, group)
        try await driver.setUp()

        let hierarchy = try await driver.viewHierarchy()
        XCTAssertEqual(hierarchy.platform, .web)
        XCTAssertEqual(hierarchy.root.tag, "html")

        let login = firstNode(in: hierarchy.root) { $0.resourceId == "login" }
        XCTAssertNotNil(login, "expected the login button in the web hierarchy")
        XCTAssertEqual(login?.text, "Login")
        XCTAssertEqual(login?.bounds, Bounds(x: 40, y: 500, width: 200, height: 48))

        try await driver.tearDown()
    }

    func testHierarchyResolvesThroughSharedElementFinder() async throws {
        let server = MockCDPServer(hierarchyJSON: sampleHierarchyJSON())
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let driver = makeDriver(server, group)
        try await driver.setUp()
        let hierarchy = try await driver.viewHierarchy()

        // The same finder used for Android resolves a web element by text.
        let finder = ElementFinder()
        let match = finder.findFirst(Selector(text: "Login"), in: hierarchy)
        XCTAssertEqual(match?.node.resourceId, "login")

        try await driver.tearDown()
    }

    func testNativeCSSAndXPathResolveBounds() async throws {
        let server = MockCDPServer(hierarchyJSON: sampleHierarchyJSON())
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let driver = makeDriver(server, group)
        try await driver.setUp()
        let css = try await driver.nativeBounds(for: Selector(css: "#login"))
        let xpath = try await driver.nativeBounds(for: Selector(xpath: "//button[@id='login']"))
        XCTAssertEqual(css, Bounds(x: 40, y: 500, width: 200, height: 48))
        XCTAssertEqual(xpath, css)
        try await driver.waitForIdle(timeoutMs: 500)
        try await driver.waitForIdle(timeoutMs: 0)
        try await driver.tearDown()
    }

    func testGesturesAndCaptureSucceed() async throws {
        let server = MockCDPServer(hierarchyJSON: sampleHierarchyJSON())
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let driver = makeDriver(server, group)
        try await driver.setUp()

        try await driver.tap(Point(x: 140, y: 524))
        try await driver.inputText("hello")
        try await driver.eraseText(2)
        try await driver.scroll(.down)
        try await driver.swipe(from: Point(x: 10, y: 10), to: Point(x: 10, y: 300), durationMs: 200)
        try await driver.pressKey(.enter)
        try await driver.openLink("about:blank")
        try await driver.setLocation(latitude: 12.34, longitude: 56.78)

        let screenshot = try await driver.screenshot()
        XCTAssertFalse(screenshot.isEmpty, "screenshot should decode from the mock's base64 data")

        try await driver.tearDown()
    }

    func testUnsupportedKeyReportsNotSupported() async throws {
        let server = MockCDPServer(hierarchyJSON: sampleHierarchyJSON())
        _ = try server.start()
        defer { server.stop() }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let driver = makeDriver(server, group)
        try await driver.setUp()

        do {
            try await driver.pressKey(.volumeUp)
            XCTFail("expected volumeUp to be unsupported on web")
        } catch let error as DriverError {
            guard case .notSupported = error else {
                return XCTFail("expected .notSupported, got \(error)")
            }
        }

        try await driver.tearDown()
    }
}
