import XCTest
import SwiftMaestroDriver
@testable import SwiftMaestroBrowser

final class WebHierarchyTests: XCTestCase {
    func testDecodeHierarchyFromEvaluateResult() throws {
        let value: [String: Any] = [
            "tag": "div",
            "resourceId": "root",
            "children": [
                ["tag": "span", "text": "Hi", "children": []],
                ["tag": "button", "resourceId": "go", "text": "Go", "clickable": true, "children": []],
            ],
        ]
        let result: [String: Any] = ["result": ["type": "object", "value": value]]

        let hierarchy = try WebHierarchy.decodeHierarchy(fromEvaluateResult: result)
        XCTAssertEqual(hierarchy.platform, .web)
        XCTAssertEqual(hierarchy.root.tag, "div")
        XCTAssertEqual(hierarchy.root.resourceId, "root")
        XCTAssertEqual(hierarchy.root.children.count, 2)
        XCTAssertEqual(hierarchy.root.children.first?.text, "Hi")
        XCTAssertEqual(hierarchy.root.children.last?.clickable, true)
    }

    func testDecodeThrowsWhenValueMissing() {
        let result: [String: Any] = ["result": ["type": "undefined"]]
        XCTAssertThrowsError(try WebHierarchy.decodeHierarchy(fromEvaluateResult: result))
    }

    func testSnapshotExpressionCarriesMarker() {
        // The mock (and any interceptor) keys off this marker to recognize the
        // DOM-snapshot evaluate call.
        XCTAssertTrue(WebHierarchy.domSnapshotExpression.contains("__swiftmaestro_dom__"))
    }
}
