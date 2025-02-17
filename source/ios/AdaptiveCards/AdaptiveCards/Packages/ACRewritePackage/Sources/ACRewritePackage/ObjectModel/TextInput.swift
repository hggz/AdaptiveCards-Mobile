import Foundation

/// Represents a text input element in an Adaptive Card.
class TextInput: BaseInputElement {
    /// Placeholder text displayed when the input is empty.
    var placeholder: String?
    
    /// The default value of the input field.
    var value: String?
    
    /// Whether the input field is multiline.
    var isMultiline: Bool
    
    /// Maximum length of the input field.
    var maxLength: UInt
    
    /// Style of the text input.
    var style: TextInputStyle?
    
    /// Optional inline action associated with the input.
    var inlineAction: BaseActionElement?
    
    /// Regular expression for validation.
    var regex: String?
    
    private enum CodingKeys: String, CodingKey {
        case placeholder, value, isMultiline, maxLength, style, inlineAction, regex
    }
    
    /// Initializes a new `TextInput` with default values.
    init() {
        self.placeholder = nil
        self.value = nil
        self.isMultiline = false
        self.maxLength = 0
        self.style = .text
        self.inlineAction = nil
        self.regex = nil
        // Use the correct parameter name for the base initializer.
        super.init(type: .textInput)
    }
    
    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.isMultiline = try container.decodeIfPresent(Bool.self, forKey: .isMultiline) ?? false
        self.maxLength = try container.decodeIfPresent(UInt.self, forKey: .maxLength) ?? 0
        self.style = try container.decodeIfPresent(TextInputStyle.self, forKey: .style)
        self.inlineAction = try container.decodeIfPresent(BaseActionElement.self, forKey: .inlineAction)
        self.regex = try container.decodeIfPresent(String.self, forKey: .regex)
        // Call the superclass decoder initializer.
        try super.init(from: decoder)
        // Optionally enforce that the type is .textInput.
        if self.type != .textInput {
            self.type = .textInput
        }
    }
    
    /// Encodes a `TextInput` to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encode(isMultiline, forKey: .isMultiline)
        try container.encode(maxLength, forKey: .maxLength)
        try container.encode(style, forKey: .style)
        try container.encodeIfPresent(inlineAction, forKey: .inlineAction)
        try container.encodeIfPresent(regex, forKey: .regex)
        try super.encode(to: encoder)
    }
}

/// Parses TextInput elements in an Adaptive Card.
struct TextInputParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> BaseCardElement {
        // Create a new TextInput using its default initializer.
        let textInput = TextInput()
        
        // Populate properties using ParseUtil helper methods.
        textInput.placeholder = try ParseUtil.getString(from: value, key: "placeholder")
        textInput.value = try ParseUtil.getString(from: value, key: "value")
        textInput.isMultiline = try ParseUtil.getBool(from: value, key: "isMultiline", defaultValue: false, required: false)
        textInput.maxLength = try ParseUtil.getUInt(from: value, key: "maxLength", defaultValue: 0, required: false)
        textInput.style = try ParseUtil.getEnumValue(from: value, key: "style", defaultValue: .text, converter: TextInputStyle.fromString)
        textInput.inlineAction = try ParseUtil.getAction(from: value, key: "inlineAction", context: context)
        textInput.regex = try ParseUtil.getString(from: value, key: "regex")
        
        // Validate style and multiline settings.
        if textInput.isMultiline && textInput.style == .password {
            context.warnings.append(
                AdaptiveCardParseWarning(
                    statusCode: .invalidValue,
                    message: "Input.Text ignores isMultiline when using password style."
                )
            )
        }
        
        return textInput
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> BaseCardElement {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
