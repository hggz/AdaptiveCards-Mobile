import XCTest
@testable import SwiftMaestroFlow

final class SelectorTests: XCTestCase {

    // MARK: - PointExpr

    func testPointExprPercent() {
        let p = PointExpr.parse("50%,50%")
        XCTAssertEqual(p, PointExpr(x: 50, y: 50, xIsPercent: true, yIsPercent: true))
    }

    func testPointExprPixels() {
        let p = PointExpr.parse("120,340")
        XCTAssertEqual(p, PointExpr(x: 120, y: 340, xIsPercent: false, yIsPercent: false))
    }

    func testPointExprToleratesWhitespace() {
        XCTAssertEqual(PointExpr.parse("10% , 60%"),
                       PointExpr(x: 10, y: 60, xIsPercent: true, yIsPercent: true))
    }

    func testPointExprRejectsBadInput() {
        XCTAssertNil(PointExpr.parse("nope"))
        XCTAssertNil(PointExpr.parse("10"))
        XCTAssertNil(PointExpr.parse("a,b"))
    }

    func testPointExprRoundTripsDescription() {
        XCTAssertEqual(PointExpr.parse("50%,50%")?.description, "50%,50%")
        XCTAssertEqual(PointExpr.parse("12,34")?.description, "12,34")
    }

    // MARK: - Direction

    func testDirectionParseIsCaseInsensitive() {
        XCTAssertEqual(Direction.parse("up"), .up)
        XCTAssertEqual(Direction.parse("DOWN"), .down)
        XCTAssertEqual(Direction.parse("Left"), .left)
        XCTAssertEqual(Direction.parse("  right "), .right)
        XCTAssertNil(Direction.parse("sideways"))
    }

    // MARK: - DeviceKey

    func testDeviceKeyParse() {
        XCTAssertEqual(DeviceKey.parse("enter"), .enter)
        XCTAssertEqual(DeviceKey.parse("Back"), .back)
        XCTAssertEqual(DeviceKey.parse("Volume Up"), .volumeUp)
        XCTAssertEqual(DeviceKey.parse("Remote Dpad Center"), .remoteCenter)
        XCTAssertEqual(DeviceKey.parse("f13"), .other("f13"))
    }

    // MARK: - GeoPoint

    func testGeoPointParse() {
        XCTAssertEqual(GeoPoint.parse("12.34,56.78"), GeoPoint(latitude: 12.34, longitude: 56.78))
        XCTAssertEqual(GeoPoint.parse("1, 2"), GeoPoint(latitude: 1, longitude: 2))
        XCTAssertNil(GeoPoint.parse("bad"))
    }

    // MARK: - Selector

    func testSelectorConvenienceAndEmptiness() {
        XCTAssertEqual(Selector.text("Hi").text, "Hi")
        XCTAssertFalse(Selector.text("Hi").isEmpty)
        XCTAssertTrue(Selector().isEmpty)
    }

    func testSelectorDescription() {
        XCTAssertEqual(Selector.text("Login").description, "text=\"Login\"")
        XCTAssertEqual(Selector(id: "btn").description, "id=\"btn\"")
    }
}
