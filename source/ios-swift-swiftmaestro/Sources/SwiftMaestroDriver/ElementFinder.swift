// Port of: pkg/driver (element finding) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation
import SwiftMaestroFlow

/// A matched element together with its position in the hierarchy.
public struct ElementMatch: Sendable, Equatable {
    public var node: ViewNode
    /// Path of child indices from the root (root == `[]`).
    public var indexPath: [Int]
    public init(node: ViewNode, indexPath: [Int]) {
        self.node = node
        self.indexPath = indexPath
    }
    public var bounds: Bounds? { node.bounds }
}

/// Resolves a `Selector` against a `ViewHierarchy`.
///
/// Supports native matchers (text/id regex, state, index), relative selectors by
/// geometry (below/above/leftOf/rightOf) and by tree position
/// (childOf/containsChild/containsDescendants), RN `testID` and Flutter semantics
/// via `accessibilityId`/`semanticsLabel`, and clickable-parent traversal.
///
/// Text/id patterns are treated as regular expressions matched against the whole
/// candidate string (an invalid pattern falls back to an exact-string compare).
/// `xpath` and complex `css` are evaluated natively by the web/CDP driver, so the
/// generic finder does not resolve them.
public struct ElementFinder: Sendable {
    public init() {}

    // MARK: - Public API

    public func findAll(_ selector: Selector, in hierarchy: ViewHierarchy, requireVisible: Bool = false) -> [ElementMatch] {
        let flat = Self.flatten(hierarchy.root)
        var indices = matchIndices(selector, flat)
        if requireVisible {
            indices = indices.filter { flat[$0].node.isVisible }
        }
        return indices.map { ElementMatch(node: flat[$0].node, indexPath: flat[$0].indexPath) }
    }

    public func findFirst(_ selector: Selector, in hierarchy: ViewHierarchy, requireVisible: Bool = false) -> ElementMatch? {
        findAll(selector, in: hierarchy, requireVisible: requireVisible).first
    }

    /// The nearest ancestor (or the element itself) marked `clickable`.
    public func clickableAncestor(of match: ElementMatch, in hierarchy: ViewHierarchy) -> ElementMatch? {
        let flat = Self.flatten(hierarchy.root)
        guard var cursor = flat.firstIndex(where: { $0.indexPath == match.indexPath }) as Int? else { return nil }
        while true {
            if flat[cursor].node.clickable == true {
                return ElementMatch(node: flat[cursor].node, indexPath: flat[cursor].indexPath)
            }
            guard let parent = flat[cursor].parent else { return nil }
            cursor = parent
        }
    }

    // MARK: - Flattening

    struct FlatNode {
        let node: ViewNode
        let indexPath: [Int]
        let parent: Int?
    }

    static func flatten(_ root: ViewNode) -> [FlatNode] {
        var out: [FlatNode] = []
        func walk(_ node: ViewNode, path: [Int], parent: Int?) {
            let myIndex = out.count
            out.append(FlatNode(node: node, indexPath: path, parent: parent))
            for (i, child) in node.children.enumerated() {
                walk(child, path: path + [i], parent: myIndex)
            }
        }
        walk(root, path: [], parent: nil)
        return out
    }

    // MARK: - Matching

    func matchIndices(_ selector: Selector, _ flat: [FlatNode]) -> [Int] {
        if selector.isEmpty { return [] }

        var indices = flat.indices.filter { Self.primaryMatch(selector, flat[$0].node) }

        if let rel = selector.below {
            let anchors = matchIndices(rel.selector, flat)
            indices = indices.filter { Self.isBelow(flat[$0], anchors: anchors, flat) }
        }
        if let rel = selector.above {
            let anchors = matchIndices(rel.selector, flat)
            indices = indices.filter { Self.isAbove(flat[$0], anchors: anchors, flat) }
        }
        if let rel = selector.leftOf {
            let anchors = matchIndices(rel.selector, flat)
            indices = indices.filter { Self.isLeftOf(flat[$0], anchors: anchors, flat) }
        }
        if let rel = selector.rightOf {
            let anchors = matchIndices(rel.selector, flat)
            indices = indices.filter { Self.isRightOf(flat[$0], anchors: anchors, flat) }
        }
        if let rel = selector.childOf {
            let anchors = Set(matchIndices(rel.selector, flat))
            indices = indices.filter { i in
                anchors.contains { Self.isStrictPrefix(flat[$0].indexPath, flat[i].indexPath) }
            }
        }
        if let rel = selector.containsChild {
            indices = indices.filter { Self.hasDescendant(matching: rel.selector, under: $0, flat, finder: self) }
        }
        for desc in selector.containsDescendants {
            indices = indices.filter { Self.hasDescendant(matching: desc, under: $0, flat, finder: self) }
        }

        if let index = selector.index {
            indices = (index >= 0 && index < indices.count) ? [indices[index]] : []
        }
        return indices
    }

    /// All present non-relative matchers must match (AND). A selector with no
    /// primary matcher matches every node (to be narrowed by relative filters).
    static func primaryMatch(_ sel: Selector, _ node: ViewNode) -> Bool {
        if let text = sel.text, !anyFullMatch(text, [node.text, node.semanticsLabel]) { return false }
        if let id = sel.id, !anyFullMatch(id, [node.resourceId, node.accessibilityId]) { return false }
        if let css = sel.css, !cssMatch(css, node) { return false }
        if sel.xpath != nil { return false } // resolved natively by the web driver
        if let e = sel.enabled, node.enabled != e { return false }
        if let c = sel.checked, node.checked != c { return false }
        if let f = sel.focused, node.focused != f { return false }
        if let s = sel.selected, node.selected != s { return false }
        return true
    }

    // MARK: - Relative geometry

    static func isBelow(_ c: FlatNode, anchors: [Int], _ flat: [FlatNode]) -> Bool {
        guard let cb = c.node.bounds else { return false }
        return anchors.contains { i in
            guard let ab = flat[i].node.bounds else { return false }
            return cb.centerY > ab.centerY && horizontalOverlap(cb, ab)
        }
    }
    static func isAbove(_ c: FlatNode, anchors: [Int], _ flat: [FlatNode]) -> Bool {
        guard let cb = c.node.bounds else { return false }
        return anchors.contains { i in
            guard let ab = flat[i].node.bounds else { return false }
            return cb.centerY < ab.centerY && horizontalOverlap(cb, ab)
        }
    }
    static func isLeftOf(_ c: FlatNode, anchors: [Int], _ flat: [FlatNode]) -> Bool {
        guard let cb = c.node.bounds else { return false }
        return anchors.contains { i in
            guard let ab = flat[i].node.bounds else { return false }
            return cb.centerX < ab.centerX && verticalOverlap(cb, ab)
        }
    }
    static func isRightOf(_ c: FlatNode, anchors: [Int], _ flat: [FlatNode]) -> Bool {
        guard let cb = c.node.bounds else { return false }
        return anchors.contains { i in
            guard let ab = flat[i].node.bounds else { return false }
            return cb.centerX > ab.centerX && verticalOverlap(cb, ab)
        }
    }

    static func horizontalOverlap(_ a: Bounds, _ b: Bounds) -> Bool { a.x < b.right && b.x < a.right }
    static func verticalOverlap(_ a: Bounds, _ b: Bounds) -> Bool { a.y < b.bottom && b.y < a.bottom }

    // MARK: - Tree position

    static func isStrictPrefix(_ prefix: [Int], _ path: [Int]) -> Bool {
        prefix.count < path.count && Array(path.prefix(prefix.count)) == prefix
    }

    static func hasDescendant(matching selector: Selector, under i: Int, _ flat: [FlatNode], finder: ElementFinder) -> Bool {
        let matches = finder.matchIndices(selector, flat)
        let anchor = flat[i].indexPath
        return matches.contains { isStrictPrefix(anchor, flat[$0].indexPath) }
    }

    // MARK: - String / css matching

    static func anyFullMatch(_ pattern: String, _ candidates: [String?]) -> Bool {
        candidates.contains { candidate in
            guard let candidate else { return false }
            return regexFullMatch(pattern, candidate)
        }
    }

    static func regexFullMatch(_ pattern: String, _ s: String) -> Bool {
        guard let re = try? NSRegularExpression(pattern: pattern) else {
            return pattern == s
        }
        let range = NSRange(s.startIndex..<s.endIndex, in: s)
        guard let match = re.firstMatch(in: s, options: [], range: range) else { return false }
        return match.range == range
    }

    static func cssMatch(_ css: String, _ node: ViewNode) -> Bool {
        if css.hasPrefix("#") {
            let id = String(css.dropFirst())
            return node.resourceId == id || node.accessibilityId == id
        }
        if let tag = node.tag, tag.caseInsensitiveCompare(css) == .orderedSame { return true }
        if let className = node.className, className == css { return true }
        return false
    }
}
