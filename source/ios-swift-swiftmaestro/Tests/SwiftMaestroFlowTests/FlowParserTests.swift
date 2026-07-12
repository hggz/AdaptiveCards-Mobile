import XCTest
@testable import SwiftMaestroFlow

final class FlowParserTests: XCTestCase {

    private func parseFixture(_ name: String) throws -> Flow {
        try FlowParser.parse(Fixtures.text(name), sourcePath: Fixtures.path(name))
    }

    // MARK: - Header

    func testHeaderConfigParsing() throws {
        let flow = try parseFixture("login-smoke.yaml")
        XCTAssertEqual(flow.appId, "com.example.app")
        XCTAssertEqual(flow.name, "Login smoke")
        XCTAssertEqual(flow.tags, ["smoke", "auth"])
        XCTAssertEqual(flow.env["USER"], "alice")
        XCTAssertEqual(flow.env["PASS"], "secret")
        XCTAssertEqual(flow.commandTimeout, 10000)
        XCTAssertEqual(flow.flowTimeout, 60000)
        XCTAssertEqual(flow.waitForIdleTimeout, 3000)
        XCTAssertEqual(flow.steps.count, 5)
    }

    func testLaunchAppShorthandAndBareBack() throws {
        let flow = try parseFixture("login-smoke.yaml")
        guard case let .launchApp(step) = flow.steps[0] else { return XCTFail("expected launchApp") }
        XCTAssertEqual(step.appId, "com.example.app")
        guard case .back = flow.steps[4] else { return XCTFail("expected back") }
    }

    func testInputTextKeepsInterpolationLiteral() throws {
        let flow = try parseFixture("login-smoke.yaml")
        guard case let .inputText(step) = flow.steps[2] else { return XCTFail("expected inputText") }
        XCTAssertEqual(step.text, "${USER}", "interpolation is resolved at run time, not parse time")
    }

    func testAssertVisibleShorthandSelector() throws {
        let flow = try parseFixture("login-smoke.yaml")
        guard case let .assertVisible(step) = flow.steps[3] else { return XCTFail("expected assertVisible") }
        XCTAssertEqual(step.selector.text, "Welcome")
    }

    // MARK: - Selectors

    func testSelectorFields() throws {
        let flow = try parseFixture("selectors.yaml")
        guard case let .tapOn(s0) = flow.steps[0] else { return XCTFail() }
        XCTAssertEqual(s0.selector.id, "login_button")

        guard case let .tapOn(s1) = flow.steps[1] else { return XCTFail() }
        XCTAssertEqual(s1.selector.text, "Sign In")
        XCTAssertEqual(s1.selector.index, 0)
        XCTAssertEqual(s1.selector.enabled, true)

        guard case let .tapOn(s2) = flow.steps[2] else { return XCTFail() }
        XCTAssertEqual(s2.selector.point, PointExpr(x: 50, y: 50, xIsPercent: true, yIsPercent: true))

        guard case let .assertVisible(s3) = flow.steps[3] else { return XCTFail() }
        XCTAssertEqual(s3.selector.checked, true)

        guard case let .tapOn(s4) = flow.steps[4] else { return XCTFail() }
        XCTAssertEqual(s4.selector.css, ".btn-primary")

        guard case let .tapOn(s5) = flow.steps[5] else { return XCTFail() }
        XCTAssertEqual(s5.selector.xpath, "//button[@id='ok']")
    }

    func testRelativeSelectors() throws {
        let flow = try parseFixture("relative-selectors.yaml")
        guard case let .tapOn(edit) = flow.steps[0] else { return XCTFail() }
        XCTAssertEqual(edit.selector.below?.selector.text, "Profile")

        guard case let .tapOn(del) = flow.steps[1] else { return XCTFail() }
        XCTAssertEqual(del.selector.rightOf?.selector.id, "row_1")

        guard case let .assertVisible(child) = flow.steps[2] else { return XCTFail() }
        XCTAssertEqual(child.selector.childOf?.selector.id, "container")

        guard case let .tapOn(x) = flow.steps[3] else { return XCTFail() }
        XCTAssertEqual(x.selector.containsDescendants.map { $0.text }, ["A", "B"])
    }

    // MARK: - Full command coverage

    func testAllCommandsFixtureStepCount() throws {
        let flow = try parseFixture("all-commands.yaml")
        XCTAssertEqual(flow.steps.count, 24)
        XCTAssertEqual(flow.steps.map { $0.commandName }, [
            "launchApp", "stopApp", "killApp", "clearState", "clearKeychain",
            "doubleTapOn", "longPressOn", "inputText", "eraseText", "copyTextFrom",
            "pasteText", "assertNotVisible", "assertTrue", "scroll", "scrollUntilVisible",
            "pressKey", "hideKeyboard", "openLink", "waitForAnimationToEnd", "takeScreenshot",
            "startRecording", "stopRecording", "setLocation", "evalScript",
        ])
    }

    func testLaunchAppTypedArguments() throws {
        let flow = try parseFixture("all-commands.yaml")
        guard case let .launchApp(step) = flow.steps[0] else { return XCTFail() }
        XCTAssertEqual(step.clearState, true)
        XCTAssertEqual(step.arguments["isTest"], .bool(true))
        XCTAssertEqual(step.arguments["count"], .int(3))
    }

    func testKillAppAndEraseTextAndAssertTrue() throws {
        let flow = try parseFixture("all-commands.yaml")
        guard case let .killApp(appId, _) = flow.steps[2] else { return XCTFail() }
        XCTAssertEqual(appId, "com.other.app")

        guard case let .eraseText(count, _) = flow.steps[8] else { return XCTFail() }
        XCTAssertEqual(count, 5)

        guard case let .assertTrue(condition, _) = flow.steps[12] else { return XCTFail() }
        XCTAssertEqual(condition, "${count == 3}")
    }

    func testScrollDefaultsDownAndScrollUntilVisible() throws {
        let flow = try parseFixture("all-commands.yaml")
        guard case let .scroll(scroll) = flow.steps[13] else { return XCTFail() }
        XCTAssertEqual(scroll.direction, .down)

        guard case let .scrollUntilVisible(suv) = flow.steps[14] else { return XCTFail() }
        XCTAssertEqual(suv.element.text, "Bottom")
        XCTAssertEqual(suv.direction, .down)
        XCTAssertEqual(suv.timeout, 20000)
    }

    func testPressKeySetLocationEvalScript() throws {
        let flow = try parseFixture("all-commands.yaml")
        guard case let .pressKey(key, _) = flow.steps[15] else { return XCTFail() }
        XCTAssertEqual(key, .enter)

        guard case let .setLocation(lat, lng, _) = flow.steps[22] else { return XCTFail() }
        XCTAssertEqual(lat, 12.34, accuracy: 0.0001)
        XCTAssertEqual(lng, 56.78, accuracy: 0.0001)

        guard case let .evalScript(script, _) = flow.steps[23] else { return XCTFail() }
        XCTAssertEqual(script, "${output.token = 'x'}")
    }

    func testWaitForAnimationAndScreenshotAndRecording() throws {
        let flow = try parseFixture("all-commands.yaml")
        guard case let .waitForAnimationToEnd(timeout, _) = flow.steps[18] else { return XCTFail() }
        XCTAssertEqual(timeout, 5000)

        guard case let .takeScreenshot(shot) = flow.steps[19] else { return XCTFail() }
        XCTAssertEqual(shot.path, "home")

        guard case let .startRecording(rec) = flow.steps[20] else { return XCTFail() }
        XCTAssertEqual(rec.path, "rec")
    }

    // MARK: - Swipe forms

    func testSwipeForms() throws {
        let flow = try parseFixture("swipe-forms.yaml")
        guard case let .swipe(byDirection) = flow.steps[0] else { return XCTFail() }
        XCTAssertEqual(byDirection.direction, .left)

        guard case let .swipe(byCoords) = flow.steps[1] else { return XCTFail() }
        XCTAssertEqual(byCoords.start, PointExpr(x: 10, y: 50, xIsPercent: true, yIsPercent: true))
        XCTAssertEqual(byCoords.end, PointExpr(x: 90, y: 50, xIsPercent: true, yIsPercent: true))
        XCTAssertEqual(byCoords.duration, 400)

        guard case let .swipe(bySelector) = flow.steps[2] else { return XCTFail() }
        XCTAssertEqual(bySelector.from?.id, "card")
        XCTAssertEqual(bySelector.direction, .up)
    }

    // MARK: - Control flow (nested commands)

    func testControlFlowNesting() throws {
        let flow = try parseFixture("control-flow.yaml")
        guard case let .runFlow(inline) = flow.steps[0] else { return XCTFail() }
        XCTAssertNil(inline.file)
        XCTAssertEqual(inline.commands.count, 2)

        guard case let .`repeat`(loop) = flow.steps[1] else { return XCTFail() }
        XCTAssertEqual(loop.times, 3)
        XCTAssertEqual(loop.commands.count, 1)

        guard case let .retry(retry) = flow.steps[2] else { return XCTFail() }
        XCTAssertEqual(retry.maxRetries, 2)

        guard case let .runFlow(guarded) = flow.steps[3] else { return XCTFail() }
        XCTAssertEqual(guarded.whenCondition?.visible?.text, "Popup")
        XCTAssertEqual(guarded.commands.count, 1)
    }

    // MARK: - Web flow (no appId)

    func testWebFlowWithoutAppId() throws {
        let flow = try parseFixture("web-flow.yaml")
        XCTAssertNil(flow.appId)
        XCTAssertEqual(flow.tags, ["web"])
        guard case let .tapOn(tap) = flow.steps[1] else { return XCTFail() }
        XCTAssertEqual(tap.selector.css, "#add-to-cart")
        guard case let .assertVisible(assert) = flow.steps[2] else { return XCTFail() }
        XCTAssertEqual(assert.selector.xpath, "//h1[text()='Cart']")
    }

    // MARK: - Travel + addMedia

    func testTravelAndAddMedia() throws {
        let flow = try parseFixture("travel.yaml")
        guard case let .travel(travel) = flow.steps[0] else { return XCTFail() }
        XCTAssertEqual(travel.points, [
            GeoPoint(latitude: 0.0, longitude: 0.0),
            GeoPoint(latitude: 1.5, longitude: 1.5),
        ])
        XCTAssertEqual(travel.speed, 7900)

        guard case let .addMedia(files, _) = flow.steps[1] else { return XCTFail() }
        XCTAssertEqual(files, ["image1.png", "image2.png"])
    }

    // MARK: - Document shapes

    func testHeaderOnlyFlowHasNoSteps() throws {
        let flow = try parseFixture("header-only.yaml")
        XCTAssertEqual(flow.appId, "com.example.only")
        XCTAssertTrue(flow.steps.isEmpty)
    }

    func testStepsOnlyFlowHasNoHeader() throws {
        let flow = try parseFixture("steps-only.yaml")
        XCTAssertNil(flow.appId)
        XCTAssertEqual(flow.steps.count, 2)
    }

    // MARK: - Labels & optional modifiers

    func testInlineLabelAndOptionalModifiers() throws {
        let flow = try parseFixture("labels-optional.yaml")
        guard case let .tapOn(tap) = flow.steps[0] else { return XCTFail() }
        XCTAssertEqual(tap.label, "tap the login button")
        XCTAssertEqual(tap.optional, true)
        XCTAssertEqual(tap.selector.text, "Login")

        guard case let .assertVisible(assert) = flow.steps[1] else { return XCTFail() }
        XCTAssertEqual(assert.label, "home visible")
        XCTAssertEqual(assert.selector.text, "Home")
    }

    // MARK: - Error handling

    func testEmptyFlowThrows() {
        XCTAssertThrowsError(try FlowParser.parse("   \n  ")) { error in
            XCTAssertEqual(error as? FlowParseError, .emptyFlow)
        }
    }

    func testUnknownCommandThrows() {
        let yaml = "appId: x\n---\n- bogusCommand: 1\n"
        XCTAssertThrowsError(try FlowParser.parse(yaml)) { error in
            XCTAssertEqual(error as? FlowParseError, .unknownCommand("bogusCommand"))
        }
    }

    func testMalformedYamlThrows() {
        let yaml = "appId: x\n---\n- tapOn: \"unterminated\n"
        XCTAssertThrowsError(try FlowParser.parse(yaml)) { error in
            guard case .malformedYAML = (error as? FlowParseError) else {
                return XCTFail("expected malformedYAML, got \(error)")
            }
        }
    }

    func testSwipeWithoutFormThrows() {
        let yaml = "appId: x\n---\n- swipe:\n    duration: 100\n"
        XCTAssertThrowsError(try FlowParser.parse(yaml)) { error in
            guard case .invalidStep(let command, _) = (error as? FlowParseError) else {
                return XCTFail("expected invalidStep, got \(error)")
            }
            XCTAssertEqual(command, "swipe")
        }
    }

    func testTapWithoutSelectorThrows() {
        let yaml = "appId: x\n---\n- tapOn:\n    label: nope\n"
        XCTAssertThrowsError(try FlowParser.parse(yaml)) { error in
            guard case .invalidStep(let command, _) = (error as? FlowParseError) else {
                return XCTFail("expected invalidStep, got \(error)")
            }
            XCTAssertEqual(command, "tapOn")
        }
    }

    func testStepWithMultipleCommandKeysThrows() {
        let yaml = "appId: x\n---\n- tapOn: A\n  scroll: true\n"
        XCTAssertThrowsError(try FlowParser.parse(yaml)) { error in
            guard case .invalidStructure = (error as? FlowParseError) else {
                return XCTFail("expected invalidStructure, got \(error)")
            }
        }
    }
}
