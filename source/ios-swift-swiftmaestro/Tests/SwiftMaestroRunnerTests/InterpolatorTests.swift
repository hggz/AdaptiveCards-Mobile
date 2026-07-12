import XCTest
@testable import SwiftMaestroRunner

final class InterpolatorTests: XCTestCase {

    func testExpandsEnvVar() {
        let interp = Interpolator(env: ["USER": "alice"])
        XCTAssertEqual(interp.expand("hello ${USER}"), "hello alice")
    }

    func testExpandsMultiple() {
        let interp = Interpolator(env: ["A": "1", "B": "2"])
        XCTAssertEqual(interp.expand("${A}-${B}"), "1-2")
    }

    func testLeavesUnknownReferenceVerbatim() {
        let interp = Interpolator(env: [:])
        XCTAssertEqual(interp.expand("x ${count == 3} y"), "x ${count == 3} y")
    }

    func testPassesPlainTextThrough() {
        XCTAssertEqual(Interpolator(env: [:]).expand("plain text"), "plain text")
    }

    func testHandlesUnclosedBraceGracefully() {
        XCTAssertEqual(Interpolator(env: ["A": "1"]).expand("start ${A} then ${oops"), "start 1 then ${oops")
    }
}
