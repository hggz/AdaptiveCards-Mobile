import Foundation

// MARK: - Consolidated SwiftBackgroundImage Legacy Support

/// Unified legacy support for SwiftBackgroundImage parsing and serialization
enum SwiftBackgroundImageLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftBackgroundImage using Codable
    static func deserialize(from json: [String: Any]) throws -> SwiftBackgroundImage {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftBackgroundImage.self, from: data)
    }
    
    /// Deserializes string into a SwiftBackgroundImage
    static func deserialize(from jsonString: String) -> SwiftBackgroundImage? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(SwiftBackgroundImage.self, from: jsonData)
    }
    
    // MARK: - Serialization Functions
    
    /// Serializes a SwiftBackgroundImage to JSON string using Codable
    static func serialize(_ backgroundImage: SwiftBackgroundImage) -> String {
        let jsonData = try? JSONEncoder().encode(backgroundImage)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
    
    /// Converts a SwiftBackgroundImage to JSON dictionary
    static func serializeToJson(_ backgroundImage: SwiftBackgroundImage) -> [String: Any] {
        guard let jsonData = try? JSONEncoder().encode(backgroundImage),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return ["url": backgroundImage.url]
        }
        return json
    }
    
    /// Converts to JSON string with pretty printing
    static func serializeToJsonString(_ backgroundImage: SwiftBackgroundImage) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(backgroundImage)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(backgroundImage, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert to JSON string"))
        }
        return jsonString
    }
}

// MARK: - SwiftBackgroundImage Extension

extension SwiftBackgroundImage {
    // Validation methods
    func shouldSerialize() -> Bool {
        return !url.isEmpty
    }
    
    // Serialization helpers
    func serialize() -> String {
        return SwiftBackgroundImageLegacySupport.serialize(self)
    }
    
    func serializeToJsonValue() -> [String: Any] {
        return SwiftBackgroundImageLegacySupport.serializeToJson(self)
    }
    
    func toJSON() -> [String: Any] {
        return SwiftBackgroundImageLegacySupport.serializeToJson(self)
    }
    
    func toJSONString() throws -> String {
        return try SwiftBackgroundImageLegacySupport.serializeToJsonString(self)
    }
    
    // Static factory methods
    static func deserialize(from json: [String: Any]) throws -> SwiftBackgroundImage {
        return try SwiftBackgroundImageLegacySupport.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) -> SwiftBackgroundImage? {
        return SwiftBackgroundImageLegacySupport.deserialize(from: jsonString)
    }
    
    static func fromJSON(_ json: [String: Any]) -> SwiftBackgroundImage? {
        return try? SwiftBackgroundImageLegacySupport.deserialize(from: json)
    }
    
    static func fromJSONString(_ jsonString: String) -> SwiftBackgroundImage? {
        return SwiftBackgroundImageLegacySupport.deserialize(from: jsonString)
    }
}
