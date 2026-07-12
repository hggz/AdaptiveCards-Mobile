import XCTest
@testable import SwiftMaestroDriver
import SwiftMaestroFlow
import SwiftMaestroProcess

final class UIAutomator2DriverTests: XCTestCase {

    private func loadXML(_ name: String) throws -> String {
        try String(contentsOf: Hierarchies.directory.appendingPathComponent(name), encoding: .utf8)
    }

    func testSetUpFetchHierarchyAndRouteGestures() async throws {
        let server = MockUIA2Server(sourceXML: try loadXML("android-source.xml"))
        let port = try server.start()
        defer { server.stop() }

        let client = UIAutomator2Client(baseURL: "http://127.0.0.1:\(port)")
        let mockAdb = MockCommandRunner()
        let adb = Adb(runner: mockAdb, serial: "emulator-5554")
        let driver = UIAutomator2Driver(adb: adb, client: client, appId: "com.example")

        // setUp hits the real HTTP mock (status + createSession).
        try await driver.setUp()

        // viewHierarchy fetches XML over HTTP, parses it, and the finder resolves.
        let hierarchy = try await driver.viewHierarchy()
        let login = ElementFinder().findFirst(Selector(text: "Login"), in: hierarchy)
        XCTAssertEqual(login?.node.resourceId, "com.example:id/login")

        // Coordinate gestures / keys route through adb; text goes directly to
        // UIAutomator2 so Unicode and shell metacharacters are preserved.
        try await driver.tap(Point(x: 100, y: 200))
        try await driver.pressKey(.enter)
        try await driver.inputText("héllo 👋 & hi")
        try await driver.hideKeyboard()
        try await driver.setLocation(latitude: 1.2, longitude: 3.4)
        try await driver.addMedia(["photo.png"])

        let calls = await mockAdb.calls
        XCTAssertTrue(calls.contains { $0.arguments == ["-s", "emulator-5554", "shell", "input", "tap", "100", "200"] },
                      "calls: \(calls)")
        XCTAssertTrue(calls.contains { $0.arguments == ["-s", "emulator-5554", "shell", "input", "keyevent", "66"] },
                      "calls: \(calls)")
        XCTAssertFalse(calls.contains { $0.arguments.contains("text") }, "Unicode input must not use adb: \(calls)")
        XCTAssertTrue(calls.contains { $0.arguments.suffix(4) == ["shell", "input", "keyevent", "111"] },
                  "calls: \(calls)")
        XCTAssertTrue(calls.contains { $0.arguments.contains("geo") && $0.arguments.contains("3.4") },
                  "calls: \(calls)")
        XCTAssertTrue(calls.contains { $0.arguments.contains("push") && $0.arguments.contains("photo.png") },
                  "calls: \(calls)")

        try await driver.tearDown()
    }

    func testViewHierarchyRequiresSession() async throws {
        let driver = UIAutomator2Driver(adb: Adb(runner: MockCommandRunner()),
                                        client: UIAutomator2Client(baseURL: "http://127.0.0.1:1"))
        do {
            _ = try await driver.viewHierarchy()
            XCTFail("expected failure without setUp")
        } catch let error as DriverError {
            guard case .toolFailure = error else { return XCTFail("wrong error: \(error)") }
        }
    }

    func testSetUpFailsAgainstDeadServer() async throws {
        let client = UIAutomator2Client(baseURL: "http://127.0.0.1:1", requestTimeoutMs: 2000)
        let driver = UIAutomator2Driver(adb: Adb(runner: MockCommandRunner()), client: client)
        do {
            try await driver.setUp()
            XCTFail("expected setUp to fail against a closed port")
        } catch {
            // expected: connection error or toolFailure
        }
    }
}
