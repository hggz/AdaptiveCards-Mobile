import Foundation

/// Represents a toggle input field in an Adaptive Card.
class SwiftToggleInput: SwiftBaseInputElement {
    // MARK: - Properties
    /// The display title for the toggle.
    let title: String?
    
    /// The default value of the toggle.
    let value: String?
    
    /// The value representing an "off" state.
    let valueOff: String
    
    /// The value representing an "on" state.
    let valueOn: String
    
    /// Whether the title should wrap.
    let wrap: Bool

    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case title
        case value
        case valueOff
        case valueOn
        case wrap
    }

    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        title = try container.decodeIfPresent(String.self, forKey: .title)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        valueOff = try container.decodeIfPresent(String.self, forKey: .valueOff) ?? "false"
        valueOn = try container.decodeIfPresent(String.self, forKey: .valueOn) ?? "true"
        wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        
        // Call super's decoding initializer
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }

    /// Encodes a `ToggleInput` to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(value, forKey: .value)
        
        // Only encode non-default values
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
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("title")
        self.knownProperties.insert("value")
        self.knownProperties.insert("valueOff")
        self.knownProperties.insert("valueOn")
        self.knownProperties.insert("wrap")
    }
}
