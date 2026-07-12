import XCTest
import SwiftMaestroFlow
import SwiftMaestroDriver
@testable import SwiftMaestroAppium

final class AppiumDriverTests: XCTestCase {
    func testAndroidDriverRoutesFullFlow() async throws {
        let server = MockAppiumServer(sourceXML: try appiumFixture("android-source.xml"))
        _ = try server.start()
        defer { server.stop() }

        let client = try AppiumClient(baseURL: server.baseURL)
        let caps = AppiumCapabilities([
            "platformName": .string("Android"),
            "appium:automationName": .string("UiAutomator2"),
        ])
        let driver = try AppiumDriver(client: client, capabilities: caps,
                                      platform: .android, appId: "com.example")
        XCTAssertEqual(driver.platform, .android)
        try await driver.setUp()
        try await driver.installApp("Example.apk")
        try await driver.launchApp("com.example", arguments: [:])

        let hierarchy = try await driver.viewHierarchy()
        XCTAssertEqual(hierarchy.platform, .android)
        XCTAssertEqual(hierarchy.root.children.first?.text, "Login")
        XCTAssertEqual(hierarchy.root.children.first?.accessibilityId, "login-button")

        try await driver.tap(Point(x: 540, y: 545))
        try await driver.longPress(Point(x: 540, y: 545))
        try await driver.inputText("hello")
        try await driver.eraseText(2)
        try await driver.swipe(from: Point(x: 1, y: 2), to: Point(x: 3, y: 4), durationMs: 200)
        try await driver.scroll(.down)
        try await driver.pressKey(.back)
        try await driver.hideKeyboard()
        try await driver.openLink("https://example.test")
        try await driver.setLocation(latitude: 1.2, longitude: 3.4)
        let screenshot = try await driver.screenshot()
        XCTAssertFalse(screenshot.isEmpty)
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("swiftmaestro-appium-driver-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temp) }
        let media = temp.appendingPathComponent("photo.png")
        try Data("PHOTO".utf8).write(to: media)
        try await driver.addMedia([media.path])
        let recording = temp.appendingPathComponent("recording").path
        try await driver.startRecording(recording)
        try await driver.stopRecording()
        XCTAssertTrue(FileManager.default.fileExists(atPath: recording + ".mp4"))
        try await driver.clearState("com.example")
        try await driver.stopApp("com.example")
        try await driver.tearDown()

        let bodies = server.recorder.requests.map(\.body)
        XCTAssertTrue(bodies.contains { $0.contains("mobile: installApp") })
        XCTAssertTrue(bodies.contains { $0.contains("mobile: activateApp") })
        XCTAssertTrue(bodies.contains { $0.contains("mobile: terminateApp") })
        XCTAssertTrue(bodies.contains { $0.contains("mobile: clearApp") })
        XCTAssertTrue(bodies.contains { $0.contains("photo.png") })
    }

    func testIOSDriverNormalizesHierarchyAndRoutesButtons() async throws {
        let server = MockAppiumServer(sourceXML: try appiumFixture("ios-source.xml"))
        _ = try server.start()
        defer { server.stop() }

        let client = try AppiumClient(baseURL: server.baseURL)
        let caps = AppiumCapabilities([
            "platformName": .string("iOS"),
            "appium:automationName": .string("XCUITest"),
        ])
        let driver = try AppiumDriver(client: client, capabilities: caps,
                                      platform: .ios, appId: "com.example")
        XCTAssertEqual(driver.platform, .ios)
        try await driver.setUp()
        let hierarchy = try await driver.viewHierarchy()
        XCTAssertEqual(hierarchy.platform, .ios)
        XCTAssertEqual(hierarchy.root.children.first?.children.first?.accessibilityId, "loginButton")
        try await driver.pressKey(.home)
        try await driver.pressKey(.enter)
        do {
            try await driver.clearState("com.example")
            XCTFail("expected iOS clearState to be deferred")
        } catch let error as DriverError {
            guard case .notSupported = error else { return XCTFail("unexpected \(error)") }
        }
        try await driver.tearDown()
    }

    func testDriverRequiresSession() async throws {
        let client = try AppiumClient(baseURL: "http://127.0.0.1:1")
        let driver = try AppiumDriver(client: client, capabilities: .init(), platform: .android)
        do {
            _ = try await driver.viewHierarchy()
            XCTFail("expected missing session")
        } catch let error as AppiumError {
            XCTAssertEqual(error, .missingSession)
        }
    }

    func testWebPlatformRejected() throws {
        let client = try AppiumClient(baseURL: "http://127.0.0.1:1")
        XCTAssertThrowsError(try AppiumDriver(client: client, capabilities: .init(), platform: .web))
    }
}
