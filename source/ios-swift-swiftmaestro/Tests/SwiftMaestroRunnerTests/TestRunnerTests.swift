import XCTest
import Foundation
@testable import SwiftMaestroRunner
import SwiftMaestroDriver
import SwiftMaestroReport

final class TestRunnerTests: XCTestCase {

    private var loginFlowPath: String {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/login.yaml")
            .path
    }

    func testRunExecutesFlowAndEmitsReports() async throws {
        let outputDir = NSTemporaryDirectory() + "swiftmaestro-report-\(UUID().uuidString)"
        defer { try? FileManager.default.removeItem(atPath: outputDir) }

        let driver = MockDriver()
        let report = try await TestRunner().run(
            path: loginFlowPath,
            driver: driver,
            options: .init(formats: ["json", "junit", "html"], outputDir: outputDir, device: "emu-1")
        )

        XCTAssertEqual(report.total, 1)
        XCTAssertEqual(report.passed, 1)
        XCTAssertTrue(report.isSuccess)
        XCTAssertEqual(report.flows.first?.device, "emu-1")
        XCTAssertEqual(report.flows.first?.name, "Login smoke")

        let fm = FileManager.default
        XCTAssertTrue(fm.fileExists(atPath: outputDir + "/report.json"))
        XCTAssertTrue(fm.fileExists(atPath: outputDir + "/report.xml"))
        XCTAssertTrue(fm.fileExists(atPath: outputDir + "/report.html"))

        let actions = await driver.actions
        XCTAssertEqual(actions.first, "setUp")
        XCTAssertEqual(actions.last, "tearDown")
    }

    func testAppFileInstalledAfterSetUp() async throws {
        let driver = MockDriver()
        _ = try await TestRunner().run(path: loginFlowPath, driver: driver, options: .init(appFile: "app.apk"))
        let actions = await driver.actions
        let setUp = try XCTUnwrap(actions.firstIndex(of: "setUp"))
        let install = try XCTUnwrap(actions.firstIndex(of: "installApp(app.apk)"))
        XCTAssertLessThan(setUp, install)
    }

    func testSetupFailureTearsDownStartedAndFailingDrivers() async {
        let first = MockDriver()
        let second = MockDriver(failSetUp: true)
        let neverStarted = MockDriver()

        do {
            _ = try await TestRunner().run(
                path: loginFlowPath,
                drivers: [first, second, neverStarted]
            )
            XCTFail("expected injected setup failure")
        } catch {
            // expected
        }

        let firstActions = await first.actions
        let secondActions = await second.actions
        let neverStartedActions = await neverStarted.actions
        XCTAssertEqual(firstActions, ["setUp", "tearDown"])
        XCTAssertEqual(secondActions, ["setUp", "tearDown"])
        XCTAssertTrue(neverStartedActions.isEmpty)
    }

    func testInstallFailureTearsDownEveryInitializedDriver() async {
        let first = MockDriver(failInstall: true)
        let second = MockDriver()

        do {
            _ = try await TestRunner().run(
                path: loginFlowPath,
                drivers: [first, second],
                options: .init(appFile: "app.apk")
            )
            XCTFail("expected injected install failure")
        } catch {
            // expected
        }

        let firstActions = await first.actions
        let secondActions = await second.actions
        XCTAssertEqual(firstActions, ["setUp", "installApp(app.apk)", "tearDown"])
        XCTAssertEqual(secondActions, ["setUp", "tearDown"])
    }

    func testExcludeTagsSkipsFlow() async throws {
        let report = try await TestRunner().run(path: loginFlowPath, driver: MockDriver(),
                                                options: .init(excludeTags: ["smoke"]))
        XCTAssertEqual(report.total, 0)
    }

    func testIncludeTagsSelectsFlow() async throws {
        let report = try await TestRunner().run(path: loginFlowPath, driver: MockDriver(),
                                                options: .init(tags: ["smoke"]))
        XCTAssertEqual(report.total, 1)
    }

    func testMissingPathThrows() async {
        let missing = NSTemporaryDirectory() + "swiftmaestro-nope-\(UUID().uuidString)"
        do {
            _ = try await TestRunner().run(path: missing, driver: MockDriver())
            XCTFail("expected an error for a missing path")
        } catch {
            // expected
        }
    }
}
