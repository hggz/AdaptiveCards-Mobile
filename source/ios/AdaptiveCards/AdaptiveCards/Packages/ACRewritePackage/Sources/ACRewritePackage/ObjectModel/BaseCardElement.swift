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
        guard let decodedType = CardElementType(rawValue: typeRaw) else {
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
}

/// Utility methods for parsing BaseCardElement.
extension BaseCardElement {
    /// Parses a BaseCardElement from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> BaseCardElement {
        guard let typeString = json["type"] as? String,
              let type = CardElementType(rawValue: typeString) else {
            throw AdaptiveCardParseError.invalidType
        }
        let spacing = (json["spacing"] as? String).flatMap { Spacing(rawValue: $0) }
        let height = (json["height"] as? String).flatMap { HeightType(rawValue: $0) }
        let targetWidth = (json["targetWidth"] as? String).flatMap { TargetWidthType(rawValue: $0) }
        let separator = json["separator"] as? Bool
        let isVisible = json["isVisible"] as? Bool ?? true
        let areaGridName = json["areaGridName"] as? String
        let id = json["id"] as? String
        return BaseCardElement(
            type: type,
            spacing: spacing,
            height: height,
            targetWidth: targetWidth,
            separator: separator,
            isVisible: isVisible,
            areaGridName: areaGridName,
            id: id
        )
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
}
