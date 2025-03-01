import Foundation

/// A protocol that represents an adaptive card element.
/// Both card and action elements must provide these basic properties.
protocol SwiftAdaptiveCardElementProtocol: Codable {
    var typeString: String { get set }
    var id: String? { get set }
}


/// Represents a base element in an Adaptive Card.
class SwiftBaseCardElement: SwiftBaseElement, SwiftAdaptiveCardElementProtocol {
    var type: SwiftCardElementType
    var spacing: SwiftSpacing?
    var height: SwiftHeightType?
    var targetWidth: SwiftTargetWidthType?
    var separator: Bool?
    var isVisible: Bool = true
    var areaGridName: String?
    var parentalId: SwiftInternalId?  // Added parentalId property
    
    override var typeString: String {
        get { return type.rawValue }
        set { /* Optionally update type if needed */ }
    }

    // MARK: - Initializers
    init(
            type: SwiftCardElementType,
            spacing: SwiftSpacing? = nil,
            height: SwiftHeightType? = nil,
            targetWidth: SwiftTargetWidthType? = nil,
            separator: Bool? = nil,
            isVisible: Bool = true,
            areaGridName: String? = nil,
            parentalId: SwiftInternalId? = nil,  // Added parameter
            id: String? = nil
    ) {
        self.type = type
        self.spacing = spacing
        self.height = height
        self.targetWidth = targetWidth
        self.separator = separator
        self.isVisible = isVisible
        self.areaGridName = areaGridName
        self.parentalId = parentalId
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
        case parentalId
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
        try container.encodeIfPresent(parentalId, forKey: .parentalId)  // Added encoding
        try super.encode(to: encoder)
    }

    /// Deserializes a BaseCardElement from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the local properties.
        let typeRaw = try container.decode(String.self, forKey: .type)
        let decodedType: SwiftCardElementType
        if typeRaw.hasPrefix("Action.") {
            // For actions, map to a generic type (e.g. .custom)
            decodedType = .custom
        } else if let validType = SwiftCardElementType(rawValue: typeRaw) {
            decodedType = validType
        } else {
            throw AdaptiveCardParseError.invalidType
        }
        self.type = decodedType
        if let spacingRaw = try container.decodeIfPresent(String.self, forKey: .spacing) {
            self.spacing = SwiftSpacing(rawValue: spacingRaw)
        }
        if let heightRaw = try container.decodeIfPresent(String.self, forKey: .height) {
            self.height = SwiftHeightType(rawValue: heightRaw)
        }
        if let targetWidthRaw = try container.decodeIfPresent(String.self, forKey: .targetWidth) {
            self.targetWidth = SwiftTargetWidthType(rawValue: targetWidthRaw)
        }
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? true
        self.areaGridName = try container.decodeIfPresent(String.self, forKey: .areaGridName)
        self.parentalId = try container.decodeIfPresent(SwiftInternalId.self, forKey: .parentalId)  // Added decoding
        // Decode the BaseElement properties.
        try super.init(from: decoder)
    }
    /// Parses a BaseCardElement from a JSON dictionary.
    // Inside BaseCardElement.swift, update the deserialize method's switch statement

    static func deserialize(from originalJson: [String: Any]) throws -> SwiftBaseCardElement {
        // 1) Unwrap first
        let unwrapped = SwiftParseUtil.unwrapAnyCodable(from: originalJson)
        guard let jsonDict = unwrapped as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        
        // 2) Now "type" is definitely a String if present
        guard let typeString = jsonDict["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        let knownTypes = [
            SwiftCardElementType.textBlock.rawValue,
            SwiftCardElementType.columnSet.rawValue,
            SwiftCardElementType.container.rawValue,
            SwiftCardElementType.column.rawValue,
            SwiftCardElementType.image.rawValue,
            SwiftCardElementType.factSet.rawValue,
            SwiftCardElementType.actionSet.rawValue,
            SwiftCardElementType.richTextBlock.rawValue,
            SwiftCardElementType.imageSet.rawValue,
            SwiftCardElementType.textInput.rawValue,
            SwiftCardElementType.numberInput.rawValue,
            SwiftCardElementType.dateInput.rawValue,
            SwiftCardElementType.timeInput.rawValue,
            SwiftCardElementType.choiceSetInput.rawValue,
            SwiftCardElementType.toggleInput.rawValue,
            SwiftCardElementType.media.rawValue,
            SwiftCardElementType.table.rawValue // This is already here from your code
        ]
        if !knownTypes.contains(typeString) {
            // For unknown types, return an UnknownElement that just preserves the JSON.
            return try SwiftUnknownElement.createFromJSON(jsonDict)
        }
        
        // 3) Convert to Data and decode
        let data = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let decoder = JSONDecoder()
        switch typeString {
        case SwiftCardElementType.textBlock.rawValue:
            return try decoder.decode(TextBlock.self, from: data)
        case SwiftCardElementType.columnSet.rawValue:
            return try decoder.decode(SwiftColumnSet.self, from: data)
        case SwiftCardElementType.container.rawValue:
            return try decoder.decode(SwiftContainer.self, from: data)
        case SwiftCardElementType.column.rawValue:
            return try decoder.decode(SwiftColumn.self, from: data)
        case SwiftCardElementType.factSet.rawValue:
            return try decoder.decode(SwiftFactSet.self, from: data)
        case SwiftCardElementType.actionSet.rawValue:
            return try decoder.decode(SwiftActionSet.self, from: data)
        case SwiftCardElementType.richTextBlock.rawValue:
            return try decoder.decode(SwiftRichTextBlock.self, from: data)
        case SwiftCardElementType.image.rawValue:
            return try decoder.decode(SwiftImage.self, from: data)
        case SwiftCardElementType.imageSet.rawValue:
            return try decoder.decode(SwiftImageSet.self, from: data)
        case SwiftCardElementType.textInput.rawValue:
            return try decoder.decode(SwiftTextInput.self, from: data)
        case SwiftCardElementType.numberInput.rawValue:
            return try decoder.decode(SwiftNumberInput.self, from: data)
        case SwiftCardElementType.dateInput.rawValue:
            return try decoder.decode(SwiftDateInput.self, from: data)
        case SwiftCardElementType.timeInput.rawValue:
            return try decoder.decode(SwiftTimeInput.self, from: data)
        case SwiftCardElementType.choiceSetInput.rawValue:
            return try decoder.decode(SwiftChoiceSetInput.self, from: data)
        case SwiftCardElementType.toggleInput.rawValue:
            return try decoder.decode(SwiftToggleInput.self, from: data)
        case SwiftCardElementType.media.rawValue:
            return try decoder.decode(SwiftMedia.self, from: data)
        case SwiftCardElementType.table.rawValue:    // Add this case
            return try decoder.decode(SwiftTable.self, from: data)
        case SwiftCardElementType.unknown.rawValue:
            fallthrough
        default:
            return try decoder.decode(SwiftBaseCardElement.self, from: data)
        }
    }

    /// Parses a BaseCardElement from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftBaseCardElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserialize(from: jsonDict)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftBaseCardElement? {
        return try? self.deserialize(from: json)
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

    static func serializeSelectAction(_ action: SwiftBaseActionElement) throws -> [String: Any] {
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
    
    // Helper method to find parent element
    func findParent() -> SwiftBaseCardElement? {
        guard let parentId = parentalId else { return nil }
        return findElement(withId: parentId)
    }
    
    // Helper method to find element by ID
    func findElement(withId id: SwiftInternalId) -> SwiftBaseCardElement? {
        // This needs to be implemented with access to the element registry
        // For now, return nil to match current behavior
        return nil
    }
    
    /// Convenience serialize method that returns a JSON string.
    public func serialize() throws -> String {
        return try SwiftParseUtil.jsonToString(self.serializeToJsonValue())
    }
    
    /// Returns the element type as a CardElementType (or .unknown if it can’t be parsed)
    var elementTypeVal: SwiftCardElementType {
        // Use the normal conversion…
        let baseType = SwiftCardElementType.fromString(self.typeString) ?? .unknown
        // But if this is a TableRow or TableCell that came in as an orphan, return .unknown.
        if baseType == .tableRow || baseType == .tableCell {
            return .unknown
        }
        return baseType
    }
}

extension SwiftBaseCardElement {
    /// Returns the type string (as originally decoded)
    var elementTypeString: String {
        return self.typeString
    }
    
    /// A convenience “parse” method used in tests.
    static func parse(json: [String: Any], context: SwiftParseContext) -> SwiftBaseCardElement? {
        // We simply attempt to deserialize and return nil if an error is thrown.
        return try? SwiftBaseCardElement.deserialize(from: json)
    }
}

