import XCTest
@testable import SwiftMaestroWDA

final class WDAClientTests: XCTestCase {
    func testPortableHTTPClientRoundTrip() async throws {
        let server = MockWDAServer(sourceXML: try wdaFixture())
        _ = try server.start()
        defer { server.stop() }

        let client = WDAClient(baseURL: server.baseURL)
        let ready = try await client.status()
        XCTAssertTrue(ready)
        let session = try await client.createSession(bundleId: "com.example")
        XCTAssertEqual(session, "WDA-MOCK-SESSION")

        let source = try await client.source(sessionId: session)
        XCTAssertTrue(source.contains("XCUIElementTypeApplication"))

        try await client.launchApp(sessionId: session, bundleId: "com.example", environment: ["MODE": "test"])
        try await client.terminateApp(sessionId: session, bundleId: "com.example")
        try await client.tap(sessionId: session, x: 10, y: 20)
        try await client.touchAndHold(sessionId: session, x: 10, y: 20, durationSeconds: 0.8)
        try await client.inputText(sessionId: session, text: "hello")
        try await client.drag(sessionId: session, fromX: 1, fromY: 2,
                              toX: 3, toY: 4, durationSeconds: 0.3)
        try await client.scroll(sessionId: session, direction: "DOWN")
        try await client.pressButton(sessionId: session, name: "home")
        try await client.openURL(sessionId: session, url: "https://example.test")
        let screenshot = try await client.screenshot(sessionId: session)
        XCTAssertFalse(screenshot.isEmpty)
        try await client.deleteSession(session)

        let requests = server.recorder.requests
        XCTAssertTrue(requests.contains { $0.method == "GET" && $0.uri == "/status" })
        XCTAssertTrue(requests.contains { $0.method == "POST" && $0.uri == "/session" && $0.body.contains("com.example") })
        XCTAssertTrue(requests.contains { $0.uri.hasSuffix("/wda/tap/0") && $0.body.contains("\"x\":10") })
        XCTAssertTrue(requests.contains { $0.uri.hasSuffix("/wda/dragfromtoforduration") })
        XCTAssertTrue(requests.contains { $0.uri.hasSuffix("/screenshot") })
        XCTAssertTrue(requests.contains { $0.method == "DELETE" && $0.uri == "/session/WDA-MOCK-SESSION" })
    }
}
