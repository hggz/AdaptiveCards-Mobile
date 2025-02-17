import Foundation

/// Represents a base action in an Adaptive Card.
/// This class is now decoupled from BaseCardElement.
class BaseActionElement: BaseElement, AdaptiveCardElementProtocol {
    var title: String = ""
    var iconUrl: String = ""
    var style: String = "default"
    var tooltip: String = ""
    var mode: Mode = .primary
    var isEnabled: Bool = true
    var role: ActionRole?
    
    override var typeString: String {
        get { return super.typeString }
        set { super.typeString = newValue }
    }

    // MARK: - Initializers

    /// Initializes a BaseActionElement using an ActionType.
    init(type: ActionType, id: String? = nil) {
        // Use the action type’s rawValue as the type string.
        self.role = (type == .openUrl ? .link : .button)
        super.init(typeString: type.rawValue, id: id)
    }

    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl) ?? ""
        self.style = try container.decodeIfPresent(String.self, forKey: .style) ?? "default"
        self.tooltip = try container.decodeIfPresent(String.self, forKey: .tooltip) ?? ""
        self.mode = try container.decodeIfPresent(Mode.self, forKey: .mode) ?? .primary
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.role = try container.decodeIfPresent(ActionRole.self, forKey: .role)
        try super.init(from: decoder)
    }

    /// Encodes the BaseActionElement.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(iconUrl, forKey: .iconUrl)
        try container.encode(style, forKey: .style)
        try container.encode(tooltip, forKey: .tooltip)
        try container.encode(mode, forKey: .mode)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(role, forKey: .role)
        try super.encode(to: encoder)
    }

    enum CodingKeys: String, CodingKey {
        case title, iconUrl, style, tooltip, mode, isEnabled, role
    }

    // MARK: - Deserialization Helpers

    /// Deserializes a BaseActionElement from a JSON string.
    /// This function is crucial and remains available for backward compatibility.
    class func deserializeAction(from jsonString: String) throws -> BaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        // Ensure the JSON contains a "type" key.
        guard let typeString = jsonDict["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Prepare the JSON data for decoding.
        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let decoder = JSONDecoder()
        
        switch typeString {
        case ActionType.openUrl.rawValue:
            return try decoder.decode(OpenUrlAction.self, from: data)
        case ActionType.showCard.rawValue:
            return try decoder.decode(ShowCardAction.self, from: data)
        case ActionType.submit.rawValue:
            return try decoder.decode(SubmitAction.self, from: data)
        case ActionType.toggleVisibility.rawValue:
            return try decoder.decode(ToggleVisibilityAction.self, from: data)
        default:
            // For any unknown or invalid type, decode as UnknownAction.
            return try decoder.decode(UnknownAction.self, from: data)
        }
    }

    /// Deserializes a BaseActionElement from a JSON dictionary.
    class func deserializeAction(from originalJson: [String: Any]) throws -> BaseActionElement {
        let data = try JSONSerialization.data(withJSONObject: originalJson, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserializeAction(from: jsonString)
    }
}
