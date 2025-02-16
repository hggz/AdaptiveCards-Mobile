import Foundation

/// The role of an action – originally defined in C++.
enum ActionRole: String, Codable {
    case button, link, tab, menu, menuItem
}

/// Represents a base action element in an Adaptive Card.
/// (Note: BaseActionElement subclasses BaseCardElement.)
class BaseActionElement: BaseCardElement {
    // Instead of “type” (declared in BaseCardElement), we use “actionType”
    let actionType: ActionType
    var title: String?
    var iconUrl: String?
    var style: String?
    var tooltip: String?
    var mode: Mode = .primary
    var isEnabled: Bool = true
    var role: ActionRole

    init(
        type: ActionType,
        title: String? = nil,
        iconUrl: String? = nil,
        style: String? = "default",
        tooltip: String? = nil,
        mode: Mode = .primary,
        isEnabled: Bool = true,
        role: ActionRole? = nil,
        id: String? = nil
    ) {
        self.actionType = type
        // Map the action’s raw value into a CardElementType (assume they match for custom types)
        let cardType = CardElementType(rawValue: type.rawValue) ?? .custom
        self.role = role ?? (type == .openUrl ? .link : .button)
        super.init(type: cardType, id: id)
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.mode = mode
        self.isEnabled = isEnabled
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeRaw = try container.decode(String.self, forKey: .type)
        guard let decodedActionType = ActionType(rawValue: typeRaw) else {
            throw AdaptiveCardParseError.invalidType
        }
        self.actionType = decodedActionType
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        self.style = try container.decodeIfPresent(String.self, forKey: .style) ?? "default"
        self.tooltip = try container.decodeIfPresent(String.self, forKey: .tooltip)
        self.mode = try container.decodeIfPresent(Mode.self, forKey: .mode) ?? .primary
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.role = try container.decodeIfPresent(ActionRole.self, forKey: .role) ?? (decodedActionType == .openUrl ? .link : .button)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actionType.rawValue, forKey: .type)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(iconUrl, forKey: .iconUrl)
        if style != "default" { try container.encode(style, forKey: .style) }
        try container.encodeIfPresent(tooltip, forKey: .tooltip)
        if mode != .primary { try container.encode(mode.rawValue, forKey: .mode) }
        if !isEnabled { try container.encode(isEnabled, forKey: .isEnabled) }
        if role != .button { try container.encode(role.rawValue, forKey: .role) }
        try super.encode(to: encoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type, title, iconUrl, style, tooltip, mode, isEnabled, role = "actionRole"
    }
    
    // MARK: - Action-Specific Deserialization
    //
    // Instead of overriding BaseCardElement.deserialize(...),
    // add new methods that return BaseActionElement.
    
    class func deserializeAction(from json: [String: Any]) throws -> BaseActionElement {
        guard let typeString = json["type"] as? String,
              let type = ActionType(rawValue: typeString) else {
            throw AdaptiveCardParseError.invalidType
        }
        let title = json["title"] as? String
        let iconUrl = json["iconUrl"] as? String
        let style = json["style"] as? String ?? "default"
        let tooltip = json["tooltip"] as? String
        let mode = (json["mode"] as? String).flatMap { Mode(rawValue: $0) } ?? .primary
        let isEnabled = json["isEnabled"] as? Bool ?? true
        let role = (json["actionRole"] as? String).flatMap { ActionRole(rawValue: $0) } ?? (type == .openUrl ? .link : .button)
        let id = json["id"] as? String
        
        return BaseActionElement(
            type: type,
            title: title,
            iconUrl: iconUrl,
            style: style,
            tooltip: tooltip,
            mode: mode,
            isEnabled: isEnabled,
            role: role,
            id: id
        )
    }
    
    class func deserializeAction(from jsonString: String) throws -> BaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserializeAction(from: jsonDict)
    }
}

extension BaseActionElement {
    /// Extracts an SVG path from the icon URL.
    func getSVGPath() -> String {
        guard let iconUrl = iconUrl else { return "" }
        let components = iconUrl.split(separator: ",").map { String($0) }
        let iconName = components.count >= 2 ? components[1] : ""
        // The icon style is determined by additional tokens; here we use the default "regular" if not provided.
        let _ = components.count > 2 ? components.last! : "regular"
        return "\(iconName)/\(iconName).json"
    }
}
