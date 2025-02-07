import Foundation

/// Represents a text input element in an Adaptive Card.
class TextInput: BaseInputElement, Codable {
    /// Placeholder text displayed when the input is empty.
    var placeholder: String?

    /// The default value of the input field.
    var value: String?

    /// Whether the input field is multiline.
    var isMultiline: Bool

    /// Maximum length of the input field.
    var maxLength: UInt

    /// Style of the text input.
    var style: TextInputStyle

    /// Optional inline action associated with the input.
    var inlineAction: BaseActionElement?

    /// Regular expression for validation.
    var regex: String?

    /// Initializes a new `TextInput` with default values.
    override init() {
        self.placeholder = nil
        self.value = nil
        self.isMultiline = false
        self.maxLength = 0
        self.style = .text
        self.inlineAction = nil
        self.regex = nil
        super.init(cardElementType: .textInput)
    }

    /// Decodes a `TextInput` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.isMultiline = try container.decodeIfPresent(Bool.self, forKey: .isMultiline) ?? false
        self.maxLength = try container.decodeIfPresent(UInt.self, forKey: .maxLength) ?? 0
        self.style = try container.decodeIfPresent(TextInputStyle.self, forKey: .style) ?? .text
        self.inlineAction = try container.decodeIfPresent(BaseActionElement.self, forKey: .inlineAction)
        self.regex = try container.decodeIfPresent(String.self, forKey: .regex)
        super.init(cardElementType: .textInput)
    }

    /// Encodes a `TextInput` to JSON.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(isMultiline, forKey: .isMultiline)
        try container.encodeIfPresent(maxLength, forKey: .maxLength)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(inlineAction, forKey: .inlineAction)
        try container.encodeIfPresent(regex, forKey: .regex)
    }

    /// Deserializes a `TextInput` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: inout ParseContext) throws -> TextInput {
        let textInput = TextInput()
        textInput.placeholder = try ParseUtil.getString(json, key: .placeholder)
        textInput.value = try ParseUtil.getString(json, key: .value)
        textInput.isMultiline = try ParseUtil.getBool(json, key: .isMultiline, defaultValue: false)
        textInput.maxLength = try ParseUtil.getUInt(json, key: .maxLength, defaultValue: 0)
        textInput.style = try ParseUtil.getEnumValue(json, key: .style, defaultValue: .text, parser: TextInputStyle.fromString)
        textInput.inlineAction = try ParseUtil.getAction(json, key: .inlineAction, context: &context)
        textInput.regex = try ParseUtil.getString(json, key: .regex)

        // Validate style and multiline settings
        if textInput.isMultiline && textInput.style == .password {
            context.warnings.append(
                AdaptiveCardParseWarning(code: .invalidValue, message: "Input.Text ignores isMultiline when using password style.")
            )
        }

        return textInput
    }

    /// Deserializes a `TextInput` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> TextInput {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardError.invalidJson
        }
        return try deserialize(from: jsonDict, context: &context)
    }

    private enum CodingKeys: String, CodingKey {
        case placeholder
        case value
        case isMultiline
        case maxLength
        case style
        case inlineAction
        case regex
    }
}
