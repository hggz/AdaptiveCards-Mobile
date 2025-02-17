import Foundation

/// Represents an icon element in an Adaptive Card.
class Icon: BaseCardElement {
    var name: String?
    var foregroundColor: ForegroundColor
    var iconSize: IconSize
    var iconStyle: IconStyle
    var selectAction: BaseActionElement?
    
    /// Designated initializer.
    init(id: String? = nil,
         name: String? = nil,
         foregroundColor: ForegroundColor = .default,
         iconSize: IconSize = .standard,
         iconStyle: IconStyle = .regular,
         selectAction: BaseActionElement? = nil) {
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
        self.foregroundColor = try container.decode(ForegroundColor.self, forKey: .foregroundColor)
        self.iconSize = try container.decode(IconSize.self, forKey: .iconSize)
        self.iconStyle = try container.decode(IconStyle.self, forKey: .iconStyle)
        self.selectAction = try container.decodeIfPresent(BaseActionElement.self, forKey: .selectAction)
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
    static func iconFromJSON(_ json: [String: Any]) -> Icon {
        return Icon(
            name: json["name"] as? String,
            foregroundColor: ForegroundColor(rawValue: json["color"] as? String ?? ForegroundColor.default.rawValue) ?? .default,
            iconSize: IconSize(rawValue: json["size"] as? String ?? IconSize.standard.rawValue) ?? .standard,
            iconStyle: IconStyle(rawValue: json["style"] as? String ?? IconStyle.regular.rawValue) ?? .regular,
            selectAction: try? BaseActionElement.deserializeAction(from: json["selectAction"] as? [String: Any] ?? [:])
        )
    }
    
    static func iconFromJSONString(_ jsonString: String) -> Icon? {
        guard let jsonDict = try? ParseUtil.getJsonDictionary(from: jsonString) else {
            return nil
        }
        return iconFromJSON(jsonDict)
    }
}

// MARK: - Icon Parser

/// Parses Icon elements in an Adaptive Card.
class IconParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String : Any]) throws -> any AdaptiveCardElementProtocol {
        return Icon.iconFromJSON(value)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        guard let icon = Icon.iconFromJSONString(value) else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid Icon JSON string")
        }
        return icon
    }
}
