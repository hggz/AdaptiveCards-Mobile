import Foundation

/// Represents a time input field in an Adaptive Card.
class SwiftTimeInput: SwiftBaseInputElement {
    // MARK: - Properties
    let max: String?
    let min: String?
    let placeholder: String?
    let value: String?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case max, min, placeholder, value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        max = try container.decodeIfPresent(String.self, forKey: .max)
        min = try container.decodeIfPresent(String.self, forKey: .min)
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("max")
        self.knownProperties.insert("min")
        self.knownProperties.insert("placeholder")
        self.knownProperties.insert("value")
    }
}
