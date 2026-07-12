// Port of: pkg/flow/selector.go (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// A point expression such as `"50%,50%"` (percentages) or `"120,340"` (pixels).
public struct PointExpr: Sendable, Equatable, CustomStringConvertible {
    public var x: Double
    public var y: Double
    public var xIsPercent: Bool
    public var yIsPercent: Bool

    public init(x: Double, y: Double, xIsPercent: Bool, yIsPercent: Bool) {
        self.x = x
        self.y = y
        self.xIsPercent = xIsPercent
        self.yIsPercent = yIsPercent
    }

    /// Parse `"<x>,<y>"` where each component is either a pixel value or a
    /// percentage (`50%`). Returns nil when the string is not a valid point.
    public static func parse(_ raw: String) -> PointExpr? {
        let parts = raw.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }
        func component(_ s: Substring) -> (Double, Bool)? {
            var t = s.trimmingCharacters(in: .whitespaces)
            var percent = false
            if t.hasSuffix("%") {
                percent = true
                t.removeLast()
            }
            guard let value = Double(t) else { return nil }
            return (value, percent)
        }
        guard let (xv, xp) = component(parts[0]),
              let (yv, yp) = component(parts[1]) else { return nil }
        return PointExpr(x: xv, y: yv, xIsPercent: xp, yIsPercent: yp)
    }

    public var description: String {
        func fmt(_ d: Double, _ pct: Bool) -> String {
            let n = d == d.rounded() ? String(Int(d)) : String(d)
            return pct ? "\(n)%" : n
        }
        return "\(fmt(x, xIsPercent)),\(fmt(y, yIsPercent))"
    }
}

/// Reference wrapper that lets `Selector` hold nested (relative) selectors while
/// remaining a value type. A `final class` with an immutable `Sendable` payload
/// is itself `Sendable`, and breaks the value-type size recursion that would
/// otherwise make `Selector` an infinitely sized struct.
public final class SelectorBox: Sendable, Equatable, CustomStringConvertible {
    public let selector: Selector
    public init(_ selector: Selector) { self.selector = selector }
    public static func == (lhs: SelectorBox, rhs: SelectorBox) -> Bool {
        lhs.selector == rhs.selector
    }
    public var description: String { selector.description }
}

/// A Maestro element selector. Any subset of fields may be set; an empty
/// selector matches nothing and is rejected by the parser.
public struct Selector: Sendable, Equatable, CustomStringConvertible {
    // Primary matchers.
    public var text: String?            // matched as a regex by Maestro semantics
    public var id: String?
    public var css: String?             // web (CDP) only
    public var xpath: String?           // web (CDP) only
    public var index: Int?
    public var point: PointExpr?

    // State matchers.
    public var enabled: Bool?
    public var checked: Bool?
    public var focused: Bool?
    public var selected: Bool?

    // Relative matchers.
    public var below: SelectorBox?
    public var above: SelectorBox?
    public var leftOf: SelectorBox?
    public var rightOf: SelectorBox?
    public var childOf: SelectorBox?
    public var containsChild: SelectorBox?
    public var containsDescendants: [Selector]

    public init(
        text: String? = nil,
        id: String? = nil,
        css: String? = nil,
        xpath: String? = nil,
        index: Int? = nil,
        point: PointExpr? = nil,
        enabled: Bool? = nil,
        checked: Bool? = nil,
        focused: Bool? = nil,
        selected: Bool? = nil,
        below: SelectorBox? = nil,
        above: SelectorBox? = nil,
        leftOf: SelectorBox? = nil,
        rightOf: SelectorBox? = nil,
        childOf: SelectorBox? = nil,
        containsChild: SelectorBox? = nil,
        containsDescendants: [Selector] = []
    ) {
        self.text = text
        self.id = id
        self.css = css
        self.xpath = xpath
        self.index = index
        self.point = point
        self.enabled = enabled
        self.checked = checked
        self.focused = focused
        self.selected = selected
        self.below = below
        self.above = above
        self.leftOf = leftOf
        self.rightOf = rightOf
        self.childOf = childOf
        self.containsChild = containsChild
        self.containsDescendants = containsDescendants
    }

    /// Convenience for the most common case: a plain text selector.
    public static func text(_ value: String) -> Selector { Selector(text: value) }

    /// True when no matcher at all is set (an invalid selector).
    public var isEmpty: Bool {
        text == nil && id == nil && css == nil && xpath == nil && index == nil
            && point == nil && enabled == nil && checked == nil && focused == nil
            && selected == nil && below == nil && above == nil && leftOf == nil
            && rightOf == nil && childOf == nil && containsChild == nil
            && containsDescendants.isEmpty
    }

    public var description: String {
        if let text { return "text=\"\(text)\"" }
        if let id { return "id=\"\(id)\"" }
        if let css { return "css=\"\(css)\"" }
        if let xpath { return "xpath=\"\(xpath)\"" }
        if let point { return "point=\(point)" }
        if let index { return "index=\(index)" }
        return "selector"
    }
}
