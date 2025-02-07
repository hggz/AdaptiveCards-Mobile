import Foundation

/// Represents an unknown element in Adaptive Cards.
struct UnknownElement: Codable {
    var elementType: String
    var additionalProperties: [String: AnyCodable]

    init(elementType: String, additionalProperties: [String: AnyCodable] = [:]) {
        self.elementType = elementType
        self.additionalProperties = additionalProperties
    }
    
    // MARK: - Dynamic CodingKey Implementation
    struct DynamicCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? { return nil }
        
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }
    
    // MARK: - Codable Conformance
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        // Decode the known property "type"
        let typeKey = DynamicCodingKey(stringValue: "type")!
        self.elementType = try container.decode(String.self, forKey: typeKey)
        
        // Capture any additional keys
        var additional = [String: AnyCodable]()
        for key in container.allKeys {
            if key.stringValue == "type" { continue }
            let value = try container.decode(AnyCodable.self, forKey: key)
            additional[key.stringValue] = value
        }
        self.additionalProperties = additional
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        let typeKey = DynamicCodingKey(stringValue: "type")!
        try container.encode(elementType, forKey: typeKey)
        for (key, value) in additionalProperties {
            let dynamicKey = DynamicCodingKey(stringValue: key)!
            try container.encode(value, forKey: dynamicKey)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Serializes the UnknownElement into a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        var json = additionalProperties.mapValues { $0.value }
        json["type"] = elementType
        return json
    }
    
    /// Converts the UnknownElement to a JSON string.
    func serialize() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: serializeToJson(), options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Deserializes an UnknownElement from a JSON dictionary.
    static func deserialize(from json: [String: Any]) -> UnknownElement? {
        guard let elementType = json["type"] as? String else {
            return nil
        }
        var additional = json
        additional.removeValue(forKey: "type")
        let wrapped = additional.mapValues { AnyCodable($0) }
        return UnknownElement(elementType: elementType, additionalProperties: wrapped)
    }
    
    /// Deserializes an UnknownElement from a JSON string.
    static func deserialize(from jsonString: String) -> UnknownElement? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonDict)
    }
}

/// A simple parser wrapper that exposes static methods for UnknownElement.
struct UnknownElementParser {
    static func deserialize(from json: [String: Any]) -> UnknownElement? {
        return UnknownElement.deserialize(from: json)
    }
    
    static func deserialize(from jsonString: String) -> UnknownElement? {
        return UnknownElement.deserialize(from: jsonString)
    }
}
