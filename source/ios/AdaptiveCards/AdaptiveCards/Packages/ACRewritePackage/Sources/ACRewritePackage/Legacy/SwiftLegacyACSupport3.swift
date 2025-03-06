import Foundation

// MARK: - Consolidated SwiftTimeInput Legacy Support

/// Unified legacy support for SwiftTimeInput parsing and serialization
enum SwiftTimeInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTimeInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftTimeInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftTimeInput.self, from: data)
    }
    
    /// Deserializes string into a SwiftTimeInput
    static func deserialize(from jsonString: String) throws -> SwiftTimeInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftTimeInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTimeInput to JSON dictionary with proper formatting
    static func serializeToJson(_ timeInput: SwiftTimeInput, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Set type property
        json["type"] = "Input.Time"
        
        // Add properties if present
        if let max = timeInput.max {
            json["max"] = max
        }
        
        if let min = timeInput.min {
            json["min"] = min
        }
        
        if let placeholder = timeInput.placeholder {
            json["placeholder"] = placeholder
        }
        
        if let value = timeInput.value {
            json["value"] = value
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses TimeInput elements in an Adaptive Card
struct SwiftTimeInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.timeInput)
        return try SwiftTimeInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTimeInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTimeInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftTimeInput Extension

internal extension SwiftTimeInput {
    // MARK: - Static Factory Methods
    
    /// Creates a SwiftTimeInput from a JSON dictionary
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftTimeInput {
        return try SwiftTimeInputLegacySupport.deserialize(from: json)
    }
    
    /// Creates a SwiftTimeInput from a JSON string
    static func createFromJSONString(_ jsonString: String) throws -> SwiftTimeInput {
        return try SwiftTimeInputLegacySupport.deserialize(from: jsonString)
    }
}

// MARK: - Consolidated SwiftChoiceSetInput Legacy Support

/// Unified legacy support for SwiftChoiceSetInput parsing and serialization
enum SwiftChoiceSetInputLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftChoiceSetInput
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftChoiceSetInput {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftChoiceSetInput.self, from: data)
    }
    
    /// Deserializes string into a SwiftChoiceSetInput
    static func deserialize(from jsonString: String) throws -> SwiftChoiceSetInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftChoiceSetInput.self, from: data)
    }
    
    // MARK: - Serialization Functions
    static func serializeToJsonString(_ choiceSetInput: SwiftChoiceSetInput) -> String? {
        guard let jsonData = try? JSONEncoder().encode(choiceSetInput) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

// MARK: - Parser Implementation

/// Parses ChoiceSetInput elements in an Adaptive Card
struct SwiftChoiceSetInputParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.choiceSetInput)
        return try SwiftChoiceSetInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftChoiceSetInputLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftChoiceSetInputLegacySupport.deserialize(from: value)
    }
}

// MARK: - SwiftChoiceSetInput Extension

internal extension SwiftChoiceSetInput {
    // MARK: - Known Properties
    
    // MARK: - Serialization Helpers
    
    /// Serializes the instance to a JSON string.
    func serializeToJson() -> String? {
        return SwiftChoiceSetInputLegacySupport.serializeToJsonString(self)
    }
}
