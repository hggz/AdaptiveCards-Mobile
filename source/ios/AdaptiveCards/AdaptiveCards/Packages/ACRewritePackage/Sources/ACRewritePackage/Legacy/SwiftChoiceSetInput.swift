import Foundation

/// Represents a ChoiceSetInput in an Adaptive Card.
class SwiftChoiceSetInput: SwiftBaseInputElement {
    // MARK: - Properties
    let isMultiSelect: Bool
    let choiceSetStyle: SwiftChoiceSetStyle
    let choices: [SwiftChoiceInput]
    let choicesData: SwiftChoicesData?
    let value: String
    let wrap: Bool
    let placeholder: String

    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case isMultiSelect  = "isMultiSelect"
        case choiceSetStyle = "style"
        case choices        = "choices"
        case choicesData    = "choicesData"
        case value          = "value"
        case wrap           = "wrap"
        case placeholder    = "placeholder"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        isMultiSelect  = try container.decodeIfPresent(Bool.self, forKey: .isMultiSelect) ?? false
        choiceSetStyle = try container.decodeIfPresent(SwiftChoiceSetStyle.self, forKey: .choiceSetStyle) ?? .compact
        choices        = try container.decodeIfPresent([SwiftChoiceInput].self, forKey: .choices) ?? []
        choicesData    = try container.decodeIfPresent(SwiftChoicesData.self, forKey: .choicesData)
        value          = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
        wrap           = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        placeholder    = try container.decodeIfPresent(String.self, forKey: .placeholder) ?? ""
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isMultiSelect, forKey: .isMultiSelect)
        try container.encode(choiceSetStyle, forKey: .choiceSetStyle)
        try container.encode(choices, forKey: .choices)
        try container.encodeIfPresent(choicesData, forKey: .choicesData)
        try container.encode(value, forKey: .value)
        try container.encode(wrap, forKey: .wrap)
        try container.encode(placeholder, forKey: .placeholder)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("isMultiSelect")
        self.knownProperties.insert("style")
        self.knownProperties.insert("choices")
        self.knownProperties.insert("choicesData")
        self.knownProperties.insert("value")
        self.knownProperties.insert("wrap")
        self.knownProperties.insert("placeholder")
    }
}
