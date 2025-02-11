import Foundation

/// Represents a toggle input field in an Adaptive Card.
class ToggleInput: BaseInputElement {
    /// The display title for the toggle.
    var title: String?

    /// The default value of the toggle.
    var value: String?

    /// The value representing an "off" state.
    var valueOff: String

    /// The value representing an "on" state.
    var valueOn: String

    /// Whether the title should wrap.
    var wrap: Bool

    /// Initializes a `ToggleInput` with default values.
    init() {
        self.title = nil
        self.value = nil
        self.valueOff = "false"
        self.valueOn = "true"
        self.wrap = false
        super.init(cardElementType: .toggleInput)
    }

    /// Decodes a `ToggleInput` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.valueOff = try container.decodeIfPresent(String.self, forKey: .valueOff) ?? "false"
        self.valueOn = try container.decodeIfPresent(String.self, forKey: .valueOn) ?? "true"
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        super.init(cardElementType: .toggleInput)
    }

    /// Encodes a `ToggleInput` to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(value, forKey: .value)
        if valueOff != "false" {
            try container.encode(valueOff, forKey: .valueOff)
        }
        if valueOn != "true" {
            try container.encode(valueOn, forKey: .valueOn)
        }
        if wrap {
            try container.encode(wrap, forKey: .wrap)
        }
    }

    /// Deserializes a `ToggleInput` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: inout ParseContext) throws -> ToggleInput {
        let toggleInput = ToggleInput()
        toggleInput.title = try ParseUtil.getString(from: json, key: "title", isRequired: true)
        toggleInput.value = try ParseUtil.getString(from: json, key: "value")
        toggleInput.wrap = try ParseUtil.getBool(from: json, key: "wrap", defaultValue: false)
        toggleInput.valueOff = try ParseUtil.getString(from: json, key: "valueOff")
        toggleInput.valueOn = try ParseUtil.getString(from: json, key: "valueOn")
        return toggleInput
    }

    /// Deserializes a `ToggleInput` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> ToggleInput {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict, context: &context)
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case value
        case valueOff
        case valueOn
        case wrap
    }
}
