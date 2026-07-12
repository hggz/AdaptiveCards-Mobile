import XCTest
import SwiftMaestroDriver
@testable import SwiftMaestroWDA

final class IOSHierarchyParserTests: XCTestCase {
    func testParsesRecordedWDASource() throws {
        let hierarchy = try IOSHierarchyParser.parse(xml: wdaFixture())
        XCTAssertEqual(hierarchy.platform, .ios)
        XCTAssertEqual(hierarchy.root.className, "XCUIElementTypeApplication")
        XCTAssertEqual(hierarchy.root.bounds, Bounds(x: 0, y: 0, width: 390, height: 844))

        let window = try XCTUnwrap(hierarchy.root.children.first)
        XCTAssertEqual(window.className, "XCUIElementTypeWindow")
        XCTAssertEqual(window.children.count, 2)

        let login = try XCTUnwrap(window.children.first { $0.accessibilityId == "loginButton" })
        XCTAssertEqual(login.text, "Login & Continue")
        XCTAssertEqual(login.resourceId, "loginButton")
        XCTAssertEqual(login.bounds, Bounds(x: 100, y: 400, width: 190, height: 49))
        XCTAssertEqual(login.enabled, true)
        XCTAssertEqual(login.visible, true)
        XCTAssertEqual(login.clickable, true)
    }

    func testCRLFSourceParses() throws {
        let crlf = try wdaFixture().replacingOccurrences(of: "\n", with: "\r\n")
        let hierarchy = try IOSHierarchyParser.parse(xml: crlf)
        XCTAssertEqual(hierarchy.root.children.first?.children.last?.text, "Login & Continue")
    }

    func testInvalidSourceThrows() {
        XCTAssertThrowsError(try IOSHierarchyParser.parse(xml: "not xml"))
    }
}
