import Foundation

/// Represents a base element in an Adaptive Card.
class BaseCardElement: BaseElement {
    var type: CardElementType
    var spacing: Spacing?
    var height: HeightType?
    var targetWidth: TargetWidthType?
    var separator: Bool?
    var isVisible: Bool = true
    var areaGridName: String?

    // MARK: - Initializers
    init(
        type: CardElementType,
        spacing: Spacing? = nil,
        height: HeightType? = nil,
        targetWidth: TargetWidthType? = nil,
        separator: Bool? = nil,
        isVisible: Bool = true,
        areaGridName: String? = nil,
        id: String? = nil
    ) {
        self.type = type
        self.spacing = spacing
        self.height = height
        self.targetWidth = targetWidth
        self.separator = separator
        self.isVisible = isVisible
        self.areaGridName = areaGridName
        // Call the BaseElement initializer with the raw value of the CardElementType.
        super.init(typeString: type.rawValue, id: id)
    }

    // MARK: - Serialization
    enum CodingKeys: String, CodingKey {
        case type
        case spacing
        case height
        case targetWidth
        case separator
        case isVisible
        case areaGridName
    }

    /// Serializes the BaseCardElement into JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encodeIfPresent(spacing?.rawValue, forKey: .spacing)
        try container.encodeIfPresent(height?.rawValue, forKey: .height)
        try container.encodeIfPresent(targetWidth?.rawValue, forKey: .targetWidth)
        try container.encodeIfPresent(separator, forKey: .separator)
        try container.encode(isVisible, forKey: .isVisible)
        try container.encodeIfPresent(areaGridName, forKey: .areaGridName)
        try super.encode(to: encoder)
    }

    /// Deserializes a BaseCardElement from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the local properties.
        let typeRaw = try container.decode(String.self, forKey: .type)
        let decodedType: CardElementType
        if typeRaw.hasPrefix("Action.") {
            // For actions, map to a generic type (e.g. .custom)
            decodedType = .custom
        } else if let validType = CardElementType(rawValue: typeRaw) {
            decodedType = validType
        } else {
            throw AdaptiveCardParseError.invalidType
        }
        self.type = decodedType
        if let spacingRaw = try container.decodeIfPresent(String.self, forKey: .spacing) {
            self.spacing = Spacing(rawValue: spacingRaw)
        }
        if let heightRaw = try container.decodeIfPresent(String.self, forKey: .height) {
            self.height = HeightType(rawValue: heightRaw)
        }
        if let targetWidthRaw = try container.decodeIfPresent(String.self, forKey: .targetWidth) {
            self.targetWidth = TargetWidthType(rawValue: targetWidthRaw)
        }
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? true
        self.areaGridName = try container.decodeIfPresent(String.self, forKey: .areaGridName)
        // Decode the BaseElement properties.
        try super.init(from: decoder)
    }
    /// Parses a BaseCardElement from a JSON dictionary.
    static func deserialize(from originalJson: [String: Any]) throws -> BaseCardElement {
        // 1) Unwrap first
        let unwrapped = ParseUtil.unwrapAnyCodable(from: originalJson)
        guard let jsonDict = unwrapped as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        
        // 2) Now "type" is definitely a String if present
        guard let typeString = jsonDict["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }

        // 3) Convert to Data and decode
        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let decoder = JSONDecoder()
        switch typeString {
        case CardElementType.textBlock.rawValue:
            return try decoder.decode(TextBlock.self, from: data)
        case CardElementType.columnSet.rawValue:
            return try decoder.decode(ColumnSet.self, from: data)
        case CardElementType.container.rawValue:
            return try decoder.decode(Container.self, from: data)
        case CardElementType.column.rawValue:
            return try decoder.decode(Column.self, from: data)
        case CardElementType.image.rawValue:
            return try decoder.decode(Image.self, from: data)
        case CardElementType.imageSet.rawValue:    // <<== Add this!
            return try decoder.decode(ImageSet.self, from: data)
        case CardElementType.inputText.rawValue:
            return try decoder.decode(TextInput.self, from: data)
        case CardElementType.inputChoiceSet.rawValue:
            return try decoder.decode(ChoiceSetInput.self, from: data)
        case CardElementType.inputToggle.rawValue:
            return try decoder.decode(ToggleInput.self, from: data)
        case CardElementType.media.rawValue:
            return try decoder.decode(Media.self, from: data)
        case CardElementType.unknown.rawValue:
            fallthrough
        default:
            return try decoder.decode(BaseCardElement.self, from: data)
        }
    }

    /// Parses a BaseCardElement from a JSON string.
    static func deserialize(from jsonString: String) throws -> BaseCardElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserialize(from: jsonDict)
    }
    
    static func fromJSON(_ json: [String: Any]) -> BaseCardElement? {
        return try? self.deserialize(from: json)
    }
    
    // MARK: - Overridable Serialization Method
    /// Serializes the BaseCardElement into a JSON dictionary.
    func serializeToJsonValue() throws -> [String: Any] {
        let json = self.toJSON()
        // Validate that the dictionary can be serialized.
        _ = try JSONSerialization.data(withJSONObject: json, options: [])
        return json
    }
    
    override func toJSON() -> [String: Any] {
        var json = super.toJSON()
        json["type"] = typeString  // Use typeString instead of type.rawValue
        
        if let spacing = spacing {
            json["spacing"] = spacing.rawValue
        }
        if let height = height {
            json["height"] = height.rawValue
        }
        if let targetWidth = targetWidth {
            json["targetWidth"] = targetWidth.rawValue
        }
        if let separator = separator {
            json["separator"] = separator
        }
        if !isVisible {
            json["isVisible"] = isVisible
        }
        if let areaGridName = areaGridName {
            json["areaGridName"] = areaGridName
        }
        
        return json
    }

    static func serializeSelectAction(_ action: BaseActionElement) throws -> [String: Any] {
        return try action.serializeToJsonValue()
    }
    
    func setAdditionalProperties(_ json: [String: Any]) {
        var codableDict = [String: AnyCodable]()
        for (key, value) in json {
            codableDict[key] = AnyCodable(value)
        }
        self.additionalProperties = codableDict
    }

    func setElementTypeString(_ type: String) {
        self.typeString = type
    }
}
