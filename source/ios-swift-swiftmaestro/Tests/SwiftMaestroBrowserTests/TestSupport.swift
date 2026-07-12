import Foundation
import XCTest
import SwiftMaestroDriver

/// Encode a JSON object literal to a compact string (for the mock's canned DOM).
func jsonString(_ object: [String: Any]) -> String {
    let data = (try? JSONSerialization.data(withJSONObject: object)) ?? Data("{}".utf8)
    return String(decoding: data, as: UTF8.self)
}

/// Depth-first search for the first `ViewNode` satisfying `predicate`.
func firstNode(in node: ViewNode, where predicate: (ViewNode) -> Bool) -> ViewNode? {
    if predicate(node) { return node }
    for child in node.children {
        if let found = firstNode(in: child, where: predicate) { return found }
    }
    return nil
}

/// True if any node in the tree has the given (trimmed, case-sensitive) text.
func treeContainsText(_ node: ViewNode, _ text: String) -> Bool {
    firstNode(in: node) { $0.text == text } != nil
}
