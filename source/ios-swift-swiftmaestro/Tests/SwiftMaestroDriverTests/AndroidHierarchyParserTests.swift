import XCTest
@testable import SwiftMaestroDriver
import SwiftMaestroFlow

final class AndroidHierarchyParserTests: XCTestCase {

    private func loadXML(_ name: String) throws -> String {
        try String(contentsOf: Hierarchies.directory.appendingPathComponent(name), encoding: .utf8)
    }

    func testParsesRecordedSource() throws {
        let hierarchy = try AndroidHierarchyParser.parse(xml: loadXML("android-source.xml"))
        XCTAssertEqual(hierarchy.platform, .android)
        XCTAssertEqual(hierarchy.root.className, "android.widget.FrameLayout")
        XCTAssertEqual(hierarchy.root.children.count, 4)
    }

    func testMapsAttributesAndBounds() throws {
        let hierarchy = try AndroidHierarchyParser.parse(xml: loadXML("android-source.xml"))
        let finder = ElementFinder()

        let login = finder.findFirst(Selector(text: "Login"), in: hierarchy)
        XCTAssertEqual(login?.node.resourceId, "com.example:id/login")
        XCTAssertEqual(login?.node.clickable, true)
        XCTAssertEqual(login?.node.checked, false)
        // "[400,500][680,590]" -> x=400 y=500 w=280 h=90
        XCTAssertEqual(login?.node.bounds, Bounds(x: 400, y: 500, width: 280, height: 90))
    }

    func testContentDescBecomesAccessibilityId() throws {
        let hierarchy = try AndroidHierarchyParser.parse(xml: loadXML("android-source.xml"))
        let finder = ElementFinder()
        // content-desc "Login button" is matched by the `id` selector.
        let byDesc = finder.findFirst(Selector(id: "Login button"), in: hierarchy)
        XCTAssertEqual(byDesc?.node.text, "Login")
    }

    func testCheckedStateAndNestedText() throws {
        let hierarchy = try AndroidHierarchyParser.parse(xml: loadXML("android-source.xml"))
        let finder = ElementFinder()
        XCTAssertEqual(finder.findFirst(Selector(checked: true), in: hierarchy)?.node.text, "Remember me")

        // Nested "alice" text sits under the clickable EditText.
        let alice = try XCTUnwrap(finder.findFirst(Selector(text: "alice"), in: hierarchy))
        let clickable = finder.clickableAncestor(of: alice, in: hierarchy)
        XCTAssertEqual(clickable?.node.resourceId, "com.example:id/username")
    }

    func testEmptyHierarchyYieldsPlaceholderRoot() throws {
        let hierarchy = try AndroidHierarchyParser.parse(xml: "<hierarchy rotation=\"0\"></hierarchy>")
        XCTAssertEqual(hierarchy.root.className, "hierarchy")
        XCTAssertTrue(hierarchy.root.children.isEmpty)
    }

    func testMalformedXMLThrows() {
        XCTAssertThrowsError(try AndroidHierarchyParser.parse(xml: "<hierarchy><node text="))
    }
}
