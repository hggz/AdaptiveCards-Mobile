import Foundation

/// Represents a number input element in an Adaptive Card.
class SwiftNumberInput: SwiftBaseInputElement {
    // MARK: - Properties
    let placeholder: String?
    let value: Double?
    let min: Double?
    let max: Double?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case placeholder, value, min, max
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        
        // For numeric values, we might need to handle both String and Number formats
        if let valueDouble = try? container.decodeIfPresent(Double.self, forKey: .value) {
            value = valueDouble
        } else if let valueString = try? container.decodeIfPresent(String.self, forKey: .value),
                  let valueDouble = Double(valueString) {
            value = valueDouble
        } else {
            value = nil
        }
        
        // Same for min/max
        if let minDouble = try? container.decodeIfPresent(Double.self, forKey: .min) {
            min = minDouble
        } else if let minString = try? container.decodeIfPresent(String.self, forKey: .min),
                  let minDouble = Double(minString) {
            min = minDouble
        } else {
            min = nil
        }
        
        if let maxDouble = try? container.decodeIfPresent(Double.self, forKey: .max) {
            max = maxDouble
        } else if let maxString = try? container.decodeIfPresent(String.self, forKey: .max),
                  let maxDouble = Double(maxString) {
            max = maxDouble
        } else {
            max = nil
        }
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(max, forKey: .max)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("placeholder")
        self.knownProperties.insert("value")
        self.knownProperties.insert("min")
        self.knownProperties.insert("max")
    }
}
