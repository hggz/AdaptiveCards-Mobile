import XCTest
import SwiftMaestroDriver

final class ManagedDriverTests: XCTestCase {
    actor Lifecycle: DriverLifecycle {
        private(set) var actions: [String] = []
        func start() async throws { actions.append("start") }
        func stop() async { actions.append("stop") }
    }

    func testManagedDriverStartsAndStopsLifecycle() async throws {
        let base = MockDriver()
        let lifecycle = Lifecycle()
        let driver = ManagedDriver(base: base, lifecycle: lifecycle)
        XCTAssertEqual(driver.platform, .android)

        try await driver.setUp()
        try await driver.inputText("hello")
        try await driver.tearDown()

        let lifecycleActions = await lifecycle.actions
        XCTAssertEqual(lifecycleActions, ["start", "stop"])
        let baseActions = await base.actions
        XCTAssertEqual(baseActions.first, "setUp")
        XCTAssertTrue(baseActions.contains("inputText(hello)"))
        XCTAssertEqual(baseActions.last, "tearDown")
    }
}
