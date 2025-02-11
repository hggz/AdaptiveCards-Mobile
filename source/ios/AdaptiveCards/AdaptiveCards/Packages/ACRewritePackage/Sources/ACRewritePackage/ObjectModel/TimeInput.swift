import Foundation

/// Represents a time input field in an Adaptive Card.
class TimeInput: BaseInputElement {
    /// The maximum valid time value (e.g., `"23:59"`).
    var max: String?

    /// The minimum valid time value (e.g., `"00:00"`).
    var min: String?

    /// Placeholder text displayed when the input is empty.
    var placeholder: String?

    /// The default time value.
    var value: String?

    /// Initializes a new `TimeInput` with default values.
    init() {
        self.max = nil
        self.min = nil
        self.placeholder = nil
        self.value = nil
        super.init(cardElementType: .timeInput)
    }

    /// Decodes a `TimeInput` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        super.init(cardElementType: .timeInput)
    }

    /// Encodes a `TimeInput` to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
    }

    /// Deserializes a `TimeInput` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: inout ParseContext) throws -> TimeInput {
        let timeInput = TimeInput()
        timeInput.max = try ParseUtil.getString(from: json, key: "max")
        timeInput.min = try ParseUtil.getString(from: json, key: "min")
        timeInput.placeholder = try ParseUtil.getString(from: json, key: "placeholder")
        timeInput.value = try ParseUtil.getString(from: json, key: "value")
        return timeInput
    }

    /// Deserializes a `TimeInput` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> TimeInput {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict, context: &context)
    }

    private enum CodingKeys: String, CodingKey {
        case max
        case min
        case placeholder
        case value
    }
}
