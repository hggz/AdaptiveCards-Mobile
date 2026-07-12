import XCTest
@testable import SwiftMaestroRunner
import SwiftMaestroFlow
import SwiftMaestroDriver
import SwiftMaestroReport

final class FlowExecutorTests: XCTestCase {

    private func flow(_ lines: [String]) throws -> Flow {
        try FlowParser.parse(lines.joined(separator: "\n"))
    }

    func testExecutesLoginFlowAgainstMock() async throws {
        let f = try flow([
            "appId: com.example",
            "env:",
            "  USER: alice",
            "---",
            "- launchApp: com.example",
            "- assertVisible: \"Welcome\"",
            "- tapOn: \"Login\"",
            "- inputText: \"${USER}\"",
            "- back",
        ])
        let driver = MockDriver()
        let result = await FlowExecutor().execute(f, on: driver)

        XCTAssertEqual(result.status, .passed)
        XCTAssertEqual(result.steps.count, 5)
        XCTAssertTrue(result.steps.allSatisfy { $0.status == .passed }, "steps: \(result.steps)")

        let actions = await driver.actions
        XCTAssertTrue(actions.contains("launchApp(com.example)"))
        XCTAssertTrue(actions.contains("tap(540,545)"), "actions: \(actions)")  // Login center
        XCTAssertTrue(actions.contains("inputText(alice)"), "interpolation resolved at run time")
        XCTAssertTrue(actions.contains("pressKey(back)"))
    }

    func testAssertVisibleFailureAbortsAndSkipsRest() async throws {
        let f = try flow([
            "appId: com.example",
            "---",
            "- assertVisible: \"Nonexistent\"",
            "- tapOn: \"Login\"",
        ])
        let result = await FlowExecutor().execute(
            f, on: MockDriver(), options: .init(commandTimeoutMs: 10, waitForIdleTimeoutMs: 0)
        )
        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.steps[0].status, .failed)
        XCTAssertEqual(result.steps[1].status, .skipped)
        XCTAssertNotNil(result.message)
    }

    func testUnsupportedDriverOpIsSkippedNotFailed() async throws {
        let f = try flow([
            "appId: com.example",
            "---",
            "- startRecording: rec",
            "- tapOn: \"Login\"",
        ])
        let result = await FlowExecutor().execute(
            f, on: MockDriver(), options: .init(commandTimeoutMs: 10, waitForIdleTimeoutMs: 0)
        )
        XCTAssertEqual(result.steps[0].status, .skipped)   // notSupported -> skipped
        XCTAssertEqual(result.steps[1].status, .passed)    // flow continues
        XCTAssertEqual(result.status, .passed)
    }

    func testOptionalStepFailureDoesNotAbort() async throws {
        let f = try flow([
            "appId: com.example",
            "---",
            "- tapOn:",
            "    text: \"Nonexistent\"",
            "    optional: true",
            "- back",
        ])
        let result = await FlowExecutor().execute(
            f, on: MockDriver(), options: .init(commandTimeoutMs: 10, waitForIdleTimeoutMs: 0)
        )
        XCTAssertEqual(result.steps[0].status, .skipped)
        XCTAssertEqual(result.steps[1].status, .passed)
        XCTAssertEqual(result.status, .passed)
    }

    func testEvalScriptPopulatesOutputForInterpolation() async throws {
        let f = try flow([
            "appId: com.example",
            "---",
            "- evalScript: \"${output.user = 'alice_' + (1 + 1)}\"",
            "- inputText: \"${output.user}\"",
            "- assertTrue: \"${output.user == 'alice_2'}\"",
        ])
        let driver = MockDriver()
        let result = await FlowExecutor().execute(f, on: driver)
        XCTAssertEqual(result.status, .passed, "steps: \(result.steps)")
        let actions = await driver.actions
        XCTAssertTrue(actions.contains("inputText(alice_2)"), "actions: \(actions)")
    }

    func testAssertTrueEvaluatesJavaScript() async throws {
        let f = try flow([
            "appId: com.example",
            "env:",
            "  COUNT: \"3\"",
            "---",
            "- assertTrue: \"Number(COUNT) === 3\"",
            "- assertTrue: \"${1 + 1 == 2}\"",
        ])
        let result = await FlowExecutor().execute(f, on: MockDriver())
        XCTAssertEqual(result.status, .passed, "steps: \(result.steps)")
        XCTAssertTrue(result.steps.allSatisfy { $0.status == .passed })
    }

    func testAssertTrueFailsOnFalseJavaScript() async throws {
        let f = try flow([
            "appId: com.example",
            "---",
            "- assertTrue: \"2 + 2 === 5\"",
        ])
        let result = await FlowExecutor().execute(f, on: MockDriver())
        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.steps[0].status, .failed)
    }

    func testRunScriptFromFileSetsOutput() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let scriptPath = dir.appendingPathComponent("s.js").path.replacingOccurrences(of: "\\", with: "/")
        try "output.token = 'xyz';".write(toFile: scriptPath, atomically: false, encoding: .utf8)

        let f = try flow([
            "appId: com.example",
            "---",
            "- runScript: '\(scriptPath)'",
            "- inputText: \"${output.token}\"",
        ])
        let driver = MockDriver()
        let result = await FlowExecutor().execute(f, on: driver)
        XCTAssertEqual(result.status, .passed, "steps: \(result.steps)")
        let actions = await driver.actions
        XCTAssertTrue(actions.contains("inputText(xyz)"), "actions: \(actions)")
    }

    func testScrollAndKeyRouteToDriver() async throws {
        let f = try flow([
            "appId: com.example",
            "---",
            "- scroll",
            "- pressKey: enter",
        ])
        let driver = MockDriver()
        _ = await FlowExecutor().execute(f, on: driver)
        let actions = await driver.actions
        XCTAssertTrue(actions.contains("scroll(DOWN)"))
        XCTAssertTrue(actions.contains("pressKey(enter)"))
    }

    func testCommandTimeoutFailsAndAborts() async throws {
        let f = try flow([
            "appId: com.example", "---", "- launchApp: com.example", "- back",
        ])
        let driver = MockDriver(onLaunch: { try? await Task.sleep(nanoseconds: 200_000_000) })
        let result = await FlowExecutor().execute(
            f, on: driver,
            options: .init(commandTimeoutMs: 20, waitForIdleTimeoutMs: 0)
        )
        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.steps[0].status, .failed)
        XCTAssertTrue(result.steps[0].message?.contains("launchApp exceeded 20ms") == true)
        XCTAssertEqual(result.steps[1].status, .skipped)
    }

    func testFlowTimeoutLimitsRemainingCommand() async throws {
        let f = try flow([
            "appId: com.example", "---",
            "- launchApp: com.example", "- launchApp: com.example",
        ])
        let sequence = LaunchDelaySequence()
        let driver = MockDriver(onLaunch: {
            if await sequence.shouldBlock() {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        })
        let result = await FlowExecutor().execute(
            f, on: driver,
            options: .init(commandTimeoutMs: 5_000, flowTimeoutMs: 500,
                           waitForIdleTimeoutMs: 0)
        )
        XCTAssertEqual(result.status, .failed)
        XCTAssertEqual(result.steps[0].status, .passed)
        XCTAssertEqual(result.steps[1].status, .failed)
    }

    func testAssertVisiblePollsForAsyncUI() async throws {
        let empty = ViewHierarchy(root: ViewNode(bounds: Bounds(x: 0, y: 0, width: 100, height: 100)),
                                  platform: .android)
        let driver = MockDriver(hierarchy: empty)
        Task {
            try? await Task.sleep(nanoseconds: 60_000_000)
            await driver.setHierarchy(MockDriver.sampleHierarchy())
        }
        let f = try flow(["appId: com.example", "---", "- assertVisible: Welcome"])
        let result = await FlowExecutor().execute(
            f, on: driver,
            options: .init(commandTimeoutMs: 500, waitForIdleTimeoutMs: 0)
        )
        XCTAssertEqual(result.status, .passed, "\(result.steps)")
    }

    func testMissingElementHasClearMaestroError() async throws {
        let f = try flow(["appId: com.example", "---", "- assertVisible: Missing"])
        let result = await FlowExecutor().execute(
            f, on: MockDriver(),
            options: .init(commandTimeoutMs: 10, waitForIdleTimeoutMs: 0)
        )
        XCTAssertEqual(result.steps[0].message, "element not found: text=\"Missing\"")
    }

    func testScreenshotWritesRelativePNGAndIdleCanDisable() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("swiftmaestro-shot-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let flowPath = directory.appendingPathComponent("flow.yaml").path
        let f = try FlowParser.parse("appId: com.example\n---\n- takeScreenshot: shots/capture\n",
                                     sourcePath: flowPath)
        let driver = MockDriver()
        let result = await FlowExecutor().execute(
            f, on: driver,
            options: .init(commandTimeoutMs: 500, waitForIdleTimeoutMs: 0)
        )
        XCTAssertEqual(result.status, .passed)
        XCTAssertTrue(FileManager.default.fileExists(atPath:
            directory.appendingPathComponent("shots/capture.png").path))
        let actions = await driver.actions
        XCTAssertFalse(actions.contains { $0.hasPrefix("waitForIdle") })
    }

    func testRelativeRunScriptAndWhileRepeat() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("swiftmaestro-relative-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try "output.n = 0;".write(to: directory.appendingPathComponent("init.js"),
                                  atomically: false, encoding: .utf8)
        let yaml = """
        appId: com.example
        ---
        - runScript: init.js
        - repeat:
            while:
              true: "${output.n < 3}"
            commands:
              - evalScript: "${output.n = output.n + 1}"
        - assertTrue: "${output.n === 3}"
        """
        let f = try FlowParser.parse(yaml,
                                     sourcePath: directory.appendingPathComponent("flow.yaml").path)
        let result = await FlowExecutor().execute(f, on: MockDriver(),
                                                  options: .init(waitForIdleTimeoutMs: 0))
        XCTAssertEqual(result.status, .passed, "\(result.steps)")
    }

    func testTravelRoutesEveryWaypoint() async throws {
        let f = Flow(appId: "com.example", steps: [
            .travel(TravelStep(points: [
                GeoPoint(latitude: 1, longitude: 2),
                GeoPoint(latitude: 3, longitude: 4),
            ])),
        ])
        let driver = MockDriver()
        let result = await FlowExecutor().execute(f, on: driver,
                                                  options: .init(waitForIdleTimeoutMs: 0))
        XCTAssertEqual(result.status, .passed)
        let actions = await driver.actions
        XCTAssertTrue(actions.contains("setLocation(1.0,2.0)"))
        XCTAssertTrue(actions.contains("setLocation(3.0,4.0)"))
    }

    func testClipboardKeyboardAndKeychainCommands() async throws {
        let f = Flow(appId: "com.example", steps: [
            .copyTextFrom(selector: Selector(text: "Welcome"), label: nil),
            .pasteText(label: nil),
            .hideKeyboard(label: nil),
            .clearKeychain(label: nil),
        ])
        let driver = MockDriver()
        let result = await FlowExecutor().execute(f, on: driver,
                                                  options: .init(waitForIdleTimeoutMs: 0))
        XCTAssertEqual(result.status, .passed, "\(result.steps)")
        let actions = await driver.actions
        XCTAssertTrue(actions.contains("inputText(Welcome)"))
        XCTAssertTrue(actions.contains("hideKeyboard"))
        XCTAssertTrue(actions.contains("clearKeychain"))
    }

    func testAddMediaResolvesRelativePaths() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("swiftmaestro-media-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let f = Flow(appId: "com.example",
                     steps: [.addMedia(files: ["photo.png"], label: nil)],
                     sourcePath: directory.appendingPathComponent("flow.yaml").path)
        let driver = MockDriver()
        let result = await FlowExecutor().execute(f, on: driver,
                                                  options: .init(waitForIdleTimeoutMs: 0))
        XCTAssertEqual(result.status, .passed)
        let actions = await driver.actions
        XCTAssertTrue(actions.contains("addMedia(\(directory.appendingPathComponent("photo.png").path))"),
                      "\(actions)")
    }
}

private actor LaunchDelaySequence {
    private var count = 0
    func shouldBlock() -> Bool {
        count += 1
        return count > 1
    }
}
