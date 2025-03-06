import Foundation

// MARK: - Consolidated SwiftSeparator Legacy Support

/// Unified legacy support for SwiftSeparator parsing and serialization
enum SwiftSeparatorLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftSeparator
    static func deserialize(from value: [String: Any]) throws -> SwiftSeparator {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftSeparator.self, from: data)
    }
    
    /// Deserializes string into a SwiftSeparator
    static func deserialize(from jsonString: String) throws -> SwiftSeparator {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftSeparator.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftSeparator to JSON dictionary with proper formatting
    static func serializeToJson(_ separator: SwiftSeparator) -> [String: Any] {
        var json: [String: Any] = [:]
        
        // Add properties
        json[SwiftAdaptiveCardSchemaKey.color.rawValue] = separator.color.rawValue
        json[SwiftAdaptiveCardSchemaKey.thickness.rawValue] = separator.thickness.rawValue
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ separator: SwiftSeparator) throws -> String {
        let json = serializeToJson(separator)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - SwiftSeparator Extension

extension SwiftSeparator {
    // Legacy static factory methods
    
    /// Decodes a `Separator` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftSeparator {
        return try SwiftSeparatorLegacySupport.deserialize(from: json)
    }
    
    /// Decodes a `Separator` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftSeparator {
        return try SwiftSeparatorLegacySupport.deserialize(from: jsonString)
    }
    
    /// Encodes `Separator` to a JSON string.
    func serialize() throws -> String {
        return try SwiftSeparatorLegacySupport.serializeToJsonString(self)
    }
}
