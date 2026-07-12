import XCTest
@testable import SwiftMaestroAppium

final class AppiumClientTests: XCTestCase {
    func testW3CRoundTripAndBasicAuthExtraction() async throws {
        let server = MockAppiumServer(sourceXML: try appiumFixture("android-source.xml"))
        _ = try server.start()
        defer { server.stop() }

        let client = try AppiumClient(baseURL: "http://demo-user:demo-pass@127.0.0.1:\(server.port)/wd/hub")
        XCTAssertFalse(client.redactedBaseURL.contains("demo-user"))
        XCTAssertFalse(client.redactedBaseURL.contains("demo-pass"))
        let ready = try await client.status()
        XCTAssertTrue(ready)

        let capabilities = AppiumCapabilities([
            "platformName": .string("Android"),
            "appium:automationName": .string("UiAutomator2"),
        ])
        let session = try await client.createSession(capabilities: capabilities)
        XCTAssertEqual(session, "APPIUM-MOCK-SESSION")
        let source = try await client.source(sessionId: session)
        XCTAssertTrue(source.contains("hierarchy"))
        try await client.tap(sessionId: session, x: 10, y: 20)
        try await client.longPress(sessionId: session, x: 10, y: 20, durationMs: 800)
        try await client.swipe(sessionId: session, from: (1, 2), to: (3, 4), durationMs: 300)
        try await client.inputText(sessionId: session, text: "hello")
        try await client.openURL(sessionId: session, url: "https://example.test")
        try await client.setLocation(sessionId: session, latitude: 1.2, longitude: 3.4)
        try await client.scroll(sessionId: session, direction: "DOWN")
        try await client.installApp(sessionId: session, appPath: "app.apk")
        try await client.activateApp(sessionId: session, appId: "com.example", platformName: "Android")
        try await client.terminateApp(sessionId: session, appId: "com.example", platformName: "Android")
        try await client.clearApp(sessionId: session, appId: "com.example")
        try await client.pressAndroidKey(sessionId: session, keyCode: 4)
        let screenshot = try await client.screenshot(sessionId: session)
        XCTAssertFalse(screenshot.isEmpty)
        try await client.deleteSession(session)

        let requests = server.recorder.requests
        let expectedAuth = "Basic " + Data("demo-user:demo-pass".utf8).base64EncodedString()
        XCTAssertTrue(requests.allSatisfy { $0.headers["authorization"] == expectedAuth })
        XCTAssertTrue(requests.contains { $0.uri.hasSuffix("/actions") && $0.body.contains("pointerMove") })
        XCTAssertTrue(requests.contains { $0.uri.hasSuffix("/execute/sync") && $0.body.contains("mobile: installApp") })
        XCTAssertTrue(requests.contains { $0.uri.hasSuffix("/appium/device/press_keycode") })
    }

    func testSessionFailureRedactsURLAndCapabilitySecrets() async throws {
        let capSecret = "CAPABILITY-SECRET-123"
        let urlPassword = "URL-PASSWORD-456"
        let authToken = Data("cloud-user:\(urlPassword)".utf8).base64EncodedString()
        let server = MockAppiumServer(sourceXML: "<hierarchy/>",
                          sessionError: "bad \(capSecret), \(urlPassword), and Basic \(authToken)")
        _ = try server.start()
        defer { server.stop() }

        let client = try AppiumClient(baseURL: "http://cloud-user:\(urlPassword)@127.0.0.1:\(server.port)")
        let capabilities = AppiumCapabilities([
            "bstack:options": .object([
                "userName": .string("cloud-user"),
                "accessKey": .string(capSecret),
            ]),
        ])
        do {
            _ = try await client.createSession(capabilities: capabilities)
            XCTFail("expected session failure")
        } catch {
            let message = "\(error)"
            XCTAssertFalse(message.contains(capSecret), message)
            XCTAssertFalse(message.contains(urlPassword), message)
            XCTAssertFalse(message.contains("cloud-user"), message)
            XCTAssertFalse(message.contains(authToken), message)
            XCTAssertTrue(message.contains("***"), message)
        }
    }
}
