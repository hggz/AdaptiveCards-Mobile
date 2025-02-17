import Foundation

/// Represents a ChoiceSetInput in an Adaptive Card.
/// Now implemented as a class that extends BaseCardElement so that it can be parsed directly.
class ChoiceSetInput: BaseCardElement {
    var isMultiSelect: Bool
    var choiceSetStyle: ChoiceSetStyle
    var choices: [ChoiceInput]
    var choicesData: ChoicesData?
    var value: String
    var wrap: Bool
    var placeholder: String

    private enum CodingKeys: String, CodingKey {
        case isMultiSelect  = "isMultiSelect"
        case choiceSetStyle = "style"
        case choices        = "choices"
        case choicesData    = "choicesData"
        case value          = "value"
        case wrap           = "wrap"
        case placeholder    = "placeholder"
    }
    /// Designated initializer.
    init(
        isMultiSelect: Bool = false,
        choiceSetStyle: ChoiceSetStyle = .compact,
        choices: [ChoiceInput] = [],
        choicesData: ChoicesData? = nil,
        value: String = "",
        wrap: Bool = false,
        placeholder: String = "",
        id: String? = nil
    ) {
        self.isMultiSelect = isMultiSelect
        self.choiceSetStyle = choiceSetStyle
        self.choices = choices
        self.choicesData = choicesData
        self.value = value
        self.wrap = wrap
        self.placeholder = placeholder
        // Initialize the BaseCardElement with a type that represents a ChoiceSetInput.
        super.init(type: .choiceSetInput, id: id)
    }

    /// Required initializer for Codable conformance.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isMultiSelect  = try container.decodeIfPresent(Bool.self,  forKey: .isMultiSelect)  ?? false
        self.choiceSetStyle = try container.decodeIfPresent(ChoiceSetStyle.self, forKey: .choiceSetStyle) ?? .compact
        self.choices        = try container.decodeIfPresent([ChoiceInput].self, forKey: .choices) ?? []
        self.choicesData    = try container.decodeIfPresent(ChoicesData.self, forKey: .choicesData)
        self.value          = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
        self.wrap           = try container.decodeIfPresent(Bool.self,  forKey: .wrap)  ?? false
        self.placeholder    = try container.decodeIfPresent(String.self, forKey: .placeholder) ?? ""
        try super.init(from: decoder)
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

    /// Serializes the instance to a JSON string.
    func serializeToJson() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

/// Parses a ChoiceSetInput element from JSON.
struct ChoiceSetInputParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // Use the new class-based deserialization.
        return try ChoiceSetInput.deserialize(from: value)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
