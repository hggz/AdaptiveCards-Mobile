// Port of: pkg/core (view hierarchy) (devicelab-dev/maestro-runner, Apache-2.0)

import Foundation

/// A normalized UI element, common across UIAutomator2 / WDA / CDP hierarchies.
/// Drivers translate their native tree (Android XML, iOS/WDA JSON, CDP DOM) into
/// this shape so the element finder is backend-agnostic.
public struct ViewNode: Sendable, Equatable, Decodable {
    public var text: String?
    public var resourceId: String?          // Android resource-id / web id
    public var accessibilityId: String?     // RN testID / iOS accessibilityIdentifier
    public var className: String?
    public var tag: String?                 // web tag name
    public var semanticsLabel: String?      // Flutter semantics label
    public var bounds: Bounds?
    public var enabled: Bool?
    public var checked: Bool?
    public var focused: Bool?
    public var selected: Bool?
    public var clickable: Bool?
    public var visible: Bool?
    public var children: [ViewNode]

    public init(text: String? = nil, resourceId: String? = nil, accessibilityId: String? = nil,
                className: String? = nil, tag: String? = nil, semanticsLabel: String? = nil,
                bounds: Bounds? = nil, enabled: Bool? = nil, checked: Bool? = nil,
                focused: Bool? = nil, selected: Bool? = nil, clickable: Bool? = nil,
                visible: Bool? = nil, children: [ViewNode] = []) {
        self.text = text
        self.resourceId = resourceId
        self.accessibilityId = accessibilityId
        self.className = className
        self.tag = tag
        self.semanticsLabel = semanticsLabel
        self.bounds = bounds
        self.enabled = enabled
        self.checked = checked
        self.focused = focused
        self.selected = selected
        self.clickable = clickable
        self.visible = visible
        self.children = children
    }

    private enum CodingKeys: String, CodingKey {
        case text, resourceId, accessibilityId, className, tag, semanticsLabel
        case bounds, enabled, checked, focused, selected, clickable, visible, children
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        text = try c.decodeIfPresent(String.self, forKey: .text)
        resourceId = try c.decodeIfPresent(String.self, forKey: .resourceId)
        accessibilityId = try c.decodeIfPresent(String.self, forKey: .accessibilityId)
        className = try c.decodeIfPresent(String.self, forKey: .className)
        tag = try c.decodeIfPresent(String.self, forKey: .tag)
        semanticsLabel = try c.decodeIfPresent(String.self, forKey: .semanticsLabel)
        bounds = try c.decodeIfPresent(Bounds.self, forKey: .bounds)
        enabled = try c.decodeIfPresent(Bool.self, forKey: .enabled)
        checked = try c.decodeIfPresent(Bool.self, forKey: .checked)
        focused = try c.decodeIfPresent(Bool.self, forKey: .focused)
        selected = try c.decodeIfPresent(Bool.self, forKey: .selected)
        clickable = try c.decodeIfPresent(Bool.self, forKey: .clickable)
        visible = try c.decodeIfPresent(Bool.self, forKey: .visible)
        children = try c.decodeIfPresent([ViewNode].self, forKey: .children) ?? []
    }

    /// Heuristic visibility: not explicitly hidden and, if bounds are known, of
    /// positive area.
    public var isVisible: Bool {
        (visible ?? true) && (bounds.map { $0.width > 0 && $0.height > 0 } ?? true)
    }
}

/// A captured UI tree plus the platform it came from.
public struct ViewHierarchy: Sendable, Equatable, Decodable {
    public var root: ViewNode
    public var platform: Platform?

    public init(root: ViewNode, platform: Platform? = nil) {
        self.root = root
        self.platform = platform
    }

    /// Decode a hierarchy from recorded JSON.
    public static func decode(fromJSON json: String) throws -> ViewHierarchy {
        try JSONDecoder().decode(ViewHierarchy.self, from: Data(json.utf8))
    }
}
