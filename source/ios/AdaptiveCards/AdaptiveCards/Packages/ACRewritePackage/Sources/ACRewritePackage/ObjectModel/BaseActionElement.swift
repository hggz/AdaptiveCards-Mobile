import Foundation

/// Represents a base action element in an Adaptive Card.
struct BaseActionElement: BaseElement, Codable {
    var type: ActionType
    var title: String?
    var iconUrl: String?
    var style: String?
    var tooltip: String?
    var mode: Mode = .primary
    var isEnabled: Bool = true
    var role: ActionRole

    // MARK: - Initializers
    init(
        type: ActionType,
        title: String? = nil,
        iconUrl: String? = nil,
        style: String? = "default",
        tooltip: String? = nil,
        mode: Mode = .primary,
        isEnabled: Bool = true,
        role: ActionRole? = nil
    ) {
        self.type = type
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.mode = mode
        self.isEnabled = isEnabled
        self.role = role ?? (type == .openUrl ? .link : .button)
    }

    // MARK: - Serialization
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case iconUrl
        case style
        case tooltip
        case mode
        case isEnabled
        case role = "actionRole"
    }

    /// Serializes the BaseActionElement into JSON.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(iconUrl, forKey: .iconUrl)
        if style != "default" { try container.encodeIfPresent(style, forKey: .style) }
        try container.encodeIfPresent(tooltip, forKey: .tooltip)
        if mode != .primary { try container.encode(mode.rawValue, forKey: .mode) }
        if !isEnabled { try container.encode(isEnabled, forKey: .isEnabled) }
        if role != .button { try container.encode(role.rawValue, forKey: .role) }
    }

    /// Deserializes a BaseActionElement from JSON.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(ActionType.self, forKey: .type)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        self.style = try container.decodeIfPresent(String.self, forKey: .style) ?? "default"
        self.tooltip = try container.decodeIfPresent(String.self, forKey: .tooltip)
        self.mode = try container.decodeIfPresent(Mode.self, forKey: .mode) ?? .primary
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.role = try container.decodeIfPresent(ActionRole.self, forKey: .role) ?? (type == .openUrl ? .link : .button)
    }
}

/// Utility methods for parsing BaseActionElement.
extension BaseActionElement {
    
    /// Parses a BaseActionElement from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> BaseActionElement {
        guard let typeString = json["type"] as? String,
              let type = ActionType(rawValue: typeString) else {
            throw AdaptiveCardParseError.invalidType
        }

        let title = json["title"] as? String
        let iconUrl = json["iconUrl"] as? String
        let style = json["style"] as? String ?? "default"
        let tooltip = json["tooltip"] as? String
        let mode = (json["mode"] as? String).flatMap(Mode.init(rawValue:)) ?? .primary
        let isEnabled = json["isEnabled"] as? Bool ?? true
        let role = (json["actionRole"] as? String).flatMap(ActionRole.init(rawValue:)) ?? (type == .openUrl ? .link : .button)

        return BaseActionElement(
            type: type,
            title: title,
            iconUrl: iconUrl,
            style: style,
            tooltip: tooltip,
            mode: mode,
            isEnabled: isEnabled,
            role: role
        )
    }

    /// Parses a BaseActionElement from a JSON string.
    static func deserialize(from jsonString: String) throws -> BaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }

        return try deserialize(from: jsonDict)
    }

    /// Extracts an SVG path from the icon URL.
    func getSVGPath() -> String {
        guard let iconUrl = iconUrl else { return "" }
        let components = iconUrl.split(separator: ",").map { String($0) }
        let iconName = components.count >= 2 ? components[1] : ""
        let iconStyle = components.count > 2 ? components.last ?? "regular" : "regular"
        return "\(iconName)/\(iconName).json"
    }
}
