import XCTest
import NIOCore
import NIOPosix
import SwiftMaestroFlow
import SwiftMaestroDriver
@testable import SwiftMaestroBrowser

/// A REAL headless-browser smoke. Skipped by default so the suite stays hermetic;
/// opt in with `SWIFTMAESTRO_BROWSER_SMOKE=1` (and a Chromium-family browser on
/// the host) to verify the launch + CDP + capture pipeline end-to-end. This is the
/// "headless browser actually runs on this host" check the runner promises.
final class BrowserSmokeTests: XCTestCase {
    func testHeadlessBrowserRealSmoke() async throws {
        guard ProcessInfo.processInfo.environment["SWIFTMAESTRO_BROWSER_SMOKE"] == "1" else {
            throw XCTSkip("set SWIFTMAESTRO_BROWSER_SMOKE=1 to run the real headless browser smoke")
        }
        guard let executable = BrowserLauncher.findBrowserExecutable() else {
            throw XCTSkip("no Chrome/Chromium/Edge found on this host")
        }

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }

        let config = BrowserLaunchConfig(executablePath: executable, headless: true, initialURL: "about:blank")
        let driver = BrowserDriver(endpoint: .launch(config), group: group)

        try await driver.setUp()

        // A real page: the DOM snapshot must have an <html> root.
        let hierarchy = try await driver.viewHierarchy()
        XCTAssertEqual(hierarchy.root.tag, "html", "expected a real DOM root from the browser")

        // Real input + geolocation override should not throw.
        try await driver.tap(Point(x: 5, y: 5))
        try await driver.setLocation(latitude: 37.33, longitude: -122.03)

        // A real PNG is well over 100 bytes.
        let screenshot = try await driver.screenshot()
        XCTAssertGreaterThan(screenshot.count, 100, "expected a non-trivial PNG from Page.captureScreenshot")

        try await driver.tearDown()
    }

    func testRealPageCSSXPathInputAndScreenshotSmoke() async throws {
        guard ProcessInfo.processInfo.environment["SWIFTMAESTRO_BROWSER_SMOKE"] == "1",
              let url = ProcessInfo.processInfo.environment["SWIFTMAESTRO_BROWSER_SMOKE_URL"] else {
            throw XCTSkip("set browser smoke env + URL to run the real page sequence")
        }
        guard let executable = BrowserLauncher.findBrowserExecutable() else {
            throw XCTSkip("no Chrome/Chromium/Edge found on this host")
        }
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer { try? group.syncShutdownGracefully() }
        let driver = BrowserDriver(endpoint: .launch(.init(executablePath: executable,
                                                            headless: true,
                                                            initialURL: "about:blank")),
                                   group: group)
        try await driver.setUp()
        try await driver.openLink(url)
        let usernameBounds = try await driver.nativeBounds(for: Selector(css: "#username"))
        let username = try XCTUnwrap(usernameBounds)
        try await driver.tap(username.center)
        try await driver.inputText("alice")
        let buttonBounds = try await driver.nativeBounds(for: Selector(xpath: "//button[@id='sign-in']"))
        let button = try XCTUnwrap(buttonBounds)
        try await driver.tap(button.center)
        var found = false
        for _ in 0..<100 {
            let hierarchy = try await driver.viewHierarchy()
            if ElementFinder().findFirst(Selector(text: "Welcome alice"), in: hierarchy) != nil {
                found = true
                break
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        XCTAssertTrue(found)
        let screenshot = try await driver.screenshot()
        XCTAssertGreaterThan(screenshot.count, 100)
        try await driver.tearDown()
    }
}
