import Foundation
import SwiftMaestroProcess
import SwiftMaestroDriver

/// A recording `CommandRunner` for the adb path — records invocations and returns
/// success without spawning anything.
actor MockCommandRunner: CommandRunner {
    private(set) var calls: [[String]] = []

    func run(_ executable: String,
             arguments: [String],
             timeoutMs: Int?,
             environment: [String: String]?) async throws -> ProcessResult {
        calls.append([executable] + arguments)
        return ProcessResult(exitCode: 0, stdout: Data(), stderr: Data())
    }
}

/// A small canned Android hierarchy (a clickable "Login" button + "Welcome")
/// encoded as JSON — what the mock DeviceLab server returns for `hierarchy`.
func sampleHierarchyJSON() -> String {
    let welcome: [String: Any] = [
        "text": "Welcome",
        "bounds": ["x": 40, "y": 100, "width": 300, "height": 60],
        "children": [],
    ]
    let login: [String: Any] = [
        "text": "Login",
        "resourceId": "com.example:id/login",
        "clickable": true,
        "bounds": ["x": 400, "y": 500, "width": 280, "height": 90],
        "children": [],
    ]
    let root: [String: Any] = [
        "className": "FrameLayout",
        "bounds": ["x": 0, "y": 0, "width": 1080, "height": 1920],
        "children": [welcome, login],
    ]
    let data = (try? JSONSerialization.data(withJSONObject: root)) ?? Data("{}".utf8)
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
