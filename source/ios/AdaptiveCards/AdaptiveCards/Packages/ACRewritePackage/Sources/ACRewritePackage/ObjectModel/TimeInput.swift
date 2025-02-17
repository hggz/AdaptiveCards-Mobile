import Foundation

/// Represents a time input field in an Adaptive Card.
class TimeInput: BaseInputElement {
    /// The maximum valid time value (e.g., "23:59").
    var max: String?
    
    /// The minimum valid time value (e.g., "00:00").
    var min: String?
    
    /// Placeholder text displayed when the input is empty.
    var placeholder: String?
    
    /// The default time value.
    var value: String?

    private enum CodingKeys: String, CodingKey {
        case max, min, placeholder, value
    }
    
    /// Initializes a new TimeInput with default values.
    init() {
        self.max = nil
        self.min = nil
        self.placeholder = nil
        self.value = nil
        // Use the updated initializer parameter 'type'
        super.init(type: .timeInput)
    }
    
    /// Decodes a TimeInput from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        try super.init(from: decoder)
        // Ensure the element type is correctly set to .timeInput
        if self.type != .timeInput {
            self.type = .timeInput
        }
    }
    
    /// Encodes a TimeInput to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try super.encode(to: encoder)
    }
}

/// Parses TimeInput elements in an Adaptive Card.
struct TimeInputParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> BaseCardElement {
        // Verify the type.
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.timeInput.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        // Use the global BaseCardElement deserialization helper and cast to TimeInput.
        guard let timeInput = try BaseCardElement.deserialize(from: value) as? TimeInput else {
            throw AdaptiveCardParseError.invalidType
        }
        return timeInput
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> BaseCardElement {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
