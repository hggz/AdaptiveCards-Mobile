import XCTest
@testable import SwiftMaestroDriver
import SwiftMaestroFlow

final class ElementFinderTests: XCTestCase {

    private let finder = ElementFinder()

    private func login() throws -> ViewHierarchy { try Hierarchies.load("login-screen.json") }
    private func grid() throws -> ViewHierarchy { try Hierarchies.load("grid.json") }

    // MARK: - Native matchers

    func testFindByText() throws {
        let matches = finder.findAll(Selector(text: "Login"), in: try login())
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.node.text, "Login")
    }

    func testFindByResourceId() throws {
        let matches = finder.findAll(Selector(id: "com.example:id/username"), in: try login())
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.node.className, "EditText")
    }

    func testFindByTestID() throws {
        // RN testID / iOS accessibilityIdentifier is matched by the `id` selector.
        let matches = finder.findAll(Selector(id: "loginButton"), in: try login())
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.node.text, "Login")
    }

    func testFindByTextRegexIsWholeStringAnchored() throws {
        let h = try login()
        XCTAssertEqual(finder.findAll(Selector(text: "User.*"), in: h).first?.node.text, "Username")
        // "ogin" is a substring of "Login" but not a whole-string match.
        XCTAssertTrue(finder.findAll(Selector(text: "ogin"), in: h).isEmpty)
    }

    func testStateMatchers() throws {
        let h = try login()
        XCTAssertEqual(finder.findAll(Selector(enabled: false), in: h).first?.node.text, "Disabled")
        XCTAssertEqual(finder.findAll(Selector(checked: true), in: h).first?.node.text, "Remember me")
    }

    func testIndexSelector() throws {
        let h = try login()
        let all = finder.findAll(Selector(text: ".*"), in: h)
        XCTAssertEqual(all.count, 8)
        XCTAssertEqual(finder.findAll(Selector(text: ".*", index: 0), in: h).first?.node.text, "Profile")
        XCTAssertEqual(finder.findAll(Selector(text: ".*", index: 1), in: h).first?.node.text, "Username")
    }

    func testNotFoundReturnsEmpty() throws {
        XCTAssertTrue(finder.findAll(Selector(text: "Nonexistent"), in: try login()).isEmpty)
        XCTAssertNil(finder.findFirst(Selector(text: "Nonexistent"), in: try login()))
    }

    // MARK: - Visibility

    func testRequireVisibleFiltersHiddenNodes() throws {
        let h = try login()
        XCTAssertEqual(finder.findAll(Selector(text: "Ghost"), in: h).count, 1)
        XCTAssertTrue(finder.findAll(Selector(text: "Ghost"), in: h, requireVisible: true).isEmpty)
    }

    // MARK: - Relative geometry

    func testRelativeBelow() throws {
        let sel = Selector(text: ".*", below: SelectorBox(Selector(text: "TopLeft")))
        let matches = finder.findAll(sel, in: try grid())
        XCTAssertEqual(matches.map { $0.node.text }, ["BottomLeft"])
    }

    func testRelativeRightOf() throws {
        let sel = Selector(text: ".*", rightOf: SelectorBox(Selector(text: "TopLeft")))
        let matches = finder.findAll(sel, in: try grid())
        XCTAssertEqual(matches.map { $0.node.text }, ["TopRight"])
    }

    func testRelativeAboveAndLeftOf() throws {
        let above = Selector(text: ".*", above: SelectorBox(Selector(text: "BottomRight")))
        XCTAssertEqual(finder.findAll(above, in: try grid()).map { $0.node.text }, ["TopRight"])

        let leftOf = Selector(text: ".*", leftOf: SelectorBox(Selector(text: "TopRight")))
        XCTAssertEqual(finder.findAll(leftOf, in: try grid()).map { $0.node.text }, ["TopLeft"])
    }

    // MARK: - Tree-position relatives

    func testChildOf() throws {
        let sel = Selector(text: "alice", childOf: SelectorBox(Selector(id: "com.example:id/username")))
        let matches = finder.findAll(sel, in: try login())
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.node.text, "alice")
    }

    func testContainsChild() throws {
        let sel = Selector(id: "com.example:id/username", containsChild: SelectorBox(Selector(text: "alice")))
        let matches = finder.findAll(sel, in: try login())
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.node.className, "EditText")
    }

    func testContainsDescendants() throws {
        // The only element containing BOTH "Login" and "Edit" is the root.
        let sel = Selector(containsDescendants: [Selector(text: "Login"), Selector(text: "Edit")])
        let matches = finder.findAll(sel, in: try login())
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches.first?.node.className, "FrameLayout")
    }

    // MARK: - Clickable-parent traversal

    func testClickableAncestor() throws {
        let h = try login()
        let alice = try XCTUnwrap(finder.findFirst(Selector(text: "alice"), in: h))
        let clickable = try XCTUnwrap(finder.clickableAncestor(of: alice, in: h))
        XCTAssertEqual(clickable.node.resourceId, "com.example:id/username")
    }

    func testClickableAncestorReturnsSelfWhenClickable() throws {
        let h = try login()
        let login = try XCTUnwrap(finder.findFirst(Selector(text: "Login"), in: h))
        let clickable = try XCTUnwrap(finder.clickableAncestor(of: login, in: h))
        XCTAssertEqual(clickable.node.text, "Login")
    }
}
