import Foundation

/// Represents a time input field in an Adaptive Card.
class SwiftTimeInput: SwiftBaseInputElement {
    var max: String?
    var min: String?
    var placeholder: String?
    var value: String?
    
    // Update initializer to match pattern
    init(id: String? = nil,
         max: String? = nil,
         min: String? = nil,
         placeholder: String? = nil,
         value: String? = nil) {
        self.max = max
        self.min = min
        self.placeholder = placeholder
        self.value = value
        super.init(type: .timeInput, id: id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case max, min, placeholder, value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle optional properties with proper decoding
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        
        // Decode base properties
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try super.encode(to: encoder)
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        // Add TimeInput specific properties
        if let max = max {
            json["max"] = max
        }
        if let min = min {
            json["min"] = min
        }
        if let placeholder = placeholder {
            json["placeholder"] = placeholder
        }
        if let value = value {
            json["value"] = value
        }
        
        return json
    }
    
    // Static creation methods
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftTimeInput {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftTimeInput.self, from: data)
    }
    
    static func createFromJSONString(_ jsonString: String) throws -> SwiftTimeInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(SwiftTimeInput.self, from: data)
    }
}

// Update parser to match pattern
class SwiftTimeInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTimeInput.createFromJSON(value)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTimeInput.createFromJSONString(value)
    }
}
