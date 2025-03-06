import Foundation

/// Represents a text input element in an Adaptive Card.
class SwiftTextInput: SwiftBaseInputElement {
    // MARK: - Properties
    /// Placeholder text displayed when the input is empty.
    let placeholder: String?
    
    /// The default value of the input field.
    let value: String?
    
    /// Whether the input field is multiline.
    let isMultiline: Bool
    
    /// Maximum length of the input field.
    let maxLength: UInt
    
    /// Style of the text input.
    let style: SwiftTextInputStyle?
    
    /// Optional inline action associated with the input.
    let inlineAction: SwiftBaseActionElement?
    
    /// Regular expression for validation.
    let regex: String?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case placeholder, value, isMultiline, maxLength, style, inlineAction, regex
    }
    
    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        isMultiline = try container.decodeIfPresent(Bool.self, forKey: .isMultiline) ?? false
        maxLength = try container.decodeIfPresent(UInt.self, forKey: .maxLength) ?? 0
        style = try container.decodeIfPresent(SwiftTextInputStyle.self, forKey: .style)
        regex = try container.decodeIfPresent(String.self, forKey: .regex)
        
        // Handle inlineAction separately
        if container.contains(.inlineAction) {
            let actionDict = try container.decode([String: AnyCodable].self, forKey: .inlineAction)
            let dict = actionDict.mapValues { $0.value }
            inlineAction = try SwiftBaseActionElement.deserializeAction(from: dict)
        } else {
            inlineAction = nil
        }
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    /// Encodes a `TextInput` to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encode(isMultiline, forKey: .isMultiline)
        try container.encode(maxLength, forKey: .maxLength)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(regex, forKey: .regex)
        
        if let action = inlineAction {
            try container.encode(AnyCodable(try action.serializeToJsonValue()), forKey: .inlineAction)
        }
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("placeholder")
        self.knownProperties.insert("value")
        self.knownProperties.insert("isMultiline")
        self.knownProperties.insert("maxLength")
        self.knownProperties.insert("style")
        self.knownProperties.insert("inlineAction")
        self.knownProperties.insert("regex")
    }
}
