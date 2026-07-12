import XCTest
@testable import SwiftMaestroDriver

final class ViewHierarchyTests: XCTestCase {

    func testDecodesRecordedHierarchy() throws {
        let h = try Hierarchies.load("login-screen.json")
        XCTAssertEqual(h.platform, .android)
        XCTAssertEqual(h.root.className, "FrameLayout")
        XCTAssertEqual(h.root.children.count, 8)
        // Optional fields absent in JSON decode to nil; children default to [].
        XCTAssertNil(h.root.text)
        XCTAssertTrue(h.root.children[0].children.isEmpty)
    }

    func testNestedNodeDecodes() throws {
        let h = try Hierarchies.load("login-screen.json")
        let editText = h.root.children[2]
        XCTAssertEqual(editText.resourceId, "com.example:id/username")
        XCTAssertEqual(editText.clickable, true)
        XCTAssertEqual(editText.children.first?.text, "alice")
    }

    func testBoundsGeometry() {
        let b = Bounds(x: 10, y: 20, width: 100, height: 40)
        XCTAssertEqual(b.right, 110)
        XCTAssertEqual(b.bottom, 60)
        XCTAssertEqual(b.centerX, 60)
        XCTAssertEqual(b.centerY, 40)
        XCTAssertEqual(b.center, Point(x: 60, y: 40))
    }

    func testVisibilityHeuristic() {
        XCTAssertTrue(ViewNode(text: "x").isVisible)
        XCTAssertFalse(ViewNode(text: "x", visible: false).isVisible)
        XCTAssertFalse(ViewNode(text: "x", bounds: Bounds(x: 0, y: 0, width: 0, height: 0)).isVisible)
    }
}
