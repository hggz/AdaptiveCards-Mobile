import Foundation

/// Represents an icon element in an Adaptive Card.
class SwiftIcon: SwiftBaseCardElement {
    var name: String?
    var foregroundColor: SwiftForegroundColor
    var iconSize: SwiftIconSize
    var iconStyle: SwiftIconStyle
    var selectAction: SwiftBaseActionElement?
    
    /// Designated initializer.
    init(id: String? = nil,
         name: String? = nil,
         foregroundColor: SwiftForegroundColor = .default,
         iconSize: SwiftIconSize = .standard,
         iconStyle: SwiftIconStyle = .regular,
         selectAction: SwiftBaseActionElement? = nil) {
        self.name = name
        self.foregroundColor = foregroundColor
        self.iconSize = iconSize
        self.iconStyle = iconStyle
        self.selectAction = selectAction
        super.init(type: .icon, id: id)
        populateKnownPropertiesSet()
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case name, foregroundColor, iconSize, iconStyle, selectAction
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.foregroundColor = try container.decode(SwiftForegroundColor.self, forKey: .foregroundColor)
        self.iconSize = try container.decode(SwiftIconSize.self, forKey: .iconSize)
        self.iconStyle = try container.decode(SwiftIconStyle.self, forKey: .iconStyle)
        self.selectAction = try container.decodeIfPresent(SwiftBaseActionElement.self, forKey: .selectAction)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(foregroundColor, forKey: .foregroundColor)
        try container.encode(iconSize, forKey: .iconSize)
        try container.encode(iconStyle, forKey: .iconStyle)
        try container.encodeIfPresent(selectAction, forKey: .selectAction)
        try super.encode(to: encoder)
    }
    
    // MARK: - JSON Serialization
    /// Converts the Icon to a JSON dictionary.
    override func toJSON() -> [String: Any] {
        var json = super.toJSON()
        if let name = name {
            json["name"] = name
        }
        if foregroundColor != .default {
            json["color"] = foregroundColor.rawValue
        }
        if iconSize != .standard {
            json["size"] = iconSize.rawValue
        }
        if iconStyle != .regular {
            json["style"] = iconStyle.rawValue
        }
        if let action = selectAction {
            json["selectAction"] = action.toJSON()
        }
        return json
    }
    
    /// Populates known properties for the Icon.
    private func populateKnownPropertiesSet() {
        self.knownProperties.insert("name")
        self.knownProperties.insert("color")
        self.knownProperties.insert("size")
        self.knownProperties.insert("style")
        self.knownProperties.insert("selectAction")
    }
    static func iconFromJSON(_ json: [String: Any]) -> SwiftIcon {
        return SwiftIcon(
            name: json["name"] as? String,
            foregroundColor: SwiftForegroundColor(rawValue: json["color"] as? String ?? SwiftForegroundColor.default.rawValue) ?? .default,
            iconSize: SwiftIconSize(rawValue: json["size"] as? String ?? SwiftIconSize.standard.rawValue) ?? .standard,
            iconStyle: SwiftIconStyle(rawValue: json["style"] as? String ?? SwiftIconStyle.regular.rawValue) ?? .regular,
            selectAction: try? SwiftBaseActionElement.deserializeAction(from: json["selectAction"] as? [String: Any] ?? [:])
        )
    }
    
    static func iconFromJSONString(_ jsonString: String) -> SwiftIcon? {
        guard let jsonDict = try? SwiftParseUtil.getJsonDictionary(from: jsonString) else {
            return nil
        }
        return iconFromJSON(jsonDict)
    }
}

// MARK: - Icon Parser

/// Parses Icon elements in an Adaptive Card.
class SwiftIconParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String : Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return SwiftIcon.iconFromJSON(value)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        guard let icon = SwiftIcon.iconFromJSONString(value) else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid Icon JSON string")
        }
        return icon
    }
}
