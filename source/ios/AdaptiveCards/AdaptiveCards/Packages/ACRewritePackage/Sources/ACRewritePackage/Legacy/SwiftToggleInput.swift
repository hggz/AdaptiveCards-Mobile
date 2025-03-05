import Foundation

/// Represents a toggle input field in an Adaptive Card.
class SwiftToggleInput: SwiftBaseInputElement {
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

    private enum CodingKeys: String, CodingKey {
        case title
        case value
        case valueOff
        case valueOn
        case wrap
    }

    /// Initializes a `ToggleInput` with default values.
    init() {
        self.title = nil
        self.value = nil
        self.valueOff = "false"
        self.valueOn = "true"
        self.wrap = false
        // Use the updated initializer parameter name `type`
        super.init(type: .toggleInput)
    }

    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.valueOff = try container.decodeIfPresent(String.self, forKey: .valueOff) ?? "false"
        self.valueOn = try container.decodeIfPresent(String.self, forKey: .valueOn) ?? "true"
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        // Call super's decoding initializer
        try super.init(from: decoder)
        // Optionally enforce that the decoded type is indeed .toggleInput
        if self.type != .toggleInput {
            self.type = .toggleInput
        }
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
        try super.encode(to: encoder)
    }
}

/// Parses ToggleInput elements in an Adaptive Card.
struct SwiftToggleInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        let toggleInput = SwiftToggleInput()
        toggleInput.title = try SwiftParseUtil.getString(from: value, key: "title", required: true)
        toggleInput.value = try SwiftParseUtil.getString(from: value, key: "value")
        toggleInput.wrap = try SwiftParseUtil.getBool(from: value, key: "wrap", defaultValue: false, required: false)
        toggleInput.valueOff = try SwiftParseUtil.getString(from: value, key: "valueOff")
        toggleInput.valueOn = try SwiftParseUtil.getString(from: value, key: "valueOn")
        return toggleInput
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
