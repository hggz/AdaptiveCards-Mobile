import XCTest
@testable import SwiftMaestroJS

final class JSValueTests: XCTestCase {
    func testDecodePrimitives() {
        XCTAssertEqual(JSValue.decode(json: "42"), .number(42))
        XCTAssertEqual(JSValue.decode(json: "3.5"), .number(3.5))
        XCTAssertEqual(JSValue.decode(json: "\"hi\""), .string("hi"))
        XCTAssertEqual(JSValue.decode(json: "true"), .bool(true))
        XCTAssertEqual(JSValue.decode(json: "false"), .bool(false))
        XCTAssertEqual(JSValue.decode(json: "null"), .null)
    }

    func testDecodeCompound() {
        XCTAssertEqual(JSValue.decode(json: "[1,2,3]"), .array([.number(1), .number(2), .number(3)]))
        XCTAssertEqual(JSValue.decode(json: "{\"a\":1,\"b\":\"c\"}"),
                       .object(["a": .number(1), "b": .string("c")]))
    }

    func testStringValue() {
        XCTAssertEqual(JSValue.number(42).stringValue, "42")
        XCTAssertEqual(JSValue.number(3.5).stringValue, "3.5")
        XCTAssertEqual(JSValue.bool(true).stringValue, "true")
        XCTAssertEqual(JSValue.string("x").stringValue, "x")
        XCTAssertEqual(JSValue.undefined.stringValue, "")
        XCTAssertEqual(JSValue.null.stringValue, "null")
    }

    func testTruthiness() {
        XCTAssertTrue(JSValue.bool(true).isTruthy)
        XCTAssertFalse(JSValue.bool(false).isTruthy)
        XCTAssertTrue(JSValue.number(1).isTruthy)
        XCTAssertFalse(JSValue.number(0).isTruthy)
        XCTAssertTrue(JSValue.string("x").isTruthy)
        XCTAssertFalse(JSValue.string("").isTruthy)
        XCTAssertFalse(JSValue.undefined.isTruthy)
        XCTAssertFalse(JSValue.null.isTruthy)
        XCTAssertTrue(JSValue.object(["a": .number(1)]).isTruthy)
    }
}
