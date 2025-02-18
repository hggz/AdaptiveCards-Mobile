import Foundation

class UnknownElement: BaseCardElement {
    var elementType: String
    var originalJSON: [String: Any] = [:]
    
    struct DynamicCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? { return nil }
        
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }
    
    init(id: String? = nil,
         elementType: String,
         additionalProperties: [String: AnyCodable] = [:]) {
        self.elementType = elementType
        // Use the designated initializer of BaseCardElement.
        super.init(
            type: .unknown,
            spacing: nil,
            height: nil,
            targetWidth: nil,
            separator: nil,
            isVisible: true,
            areaGridName: nil,
            id: id
        )
        self.additionalProperties = additionalProperties
    }
    
    required init(from decoder: Decoder) throws {
        // Use a dynamic container to capture all keys.
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        var dict = [String: AnyCodable]()
        for key in container.allKeys {
            dict[key.stringValue] = try container.decode(AnyCodable.self, forKey: key)
        }
        // Save the original JSON.
        self.originalJSON = dict.mapValues { $0.value }
        // Set elementType from the original JSON.
        self.elementType = self.originalJSON["type"] as? String ?? "Unknown"
        // Call the designated initializer of the superclass.
        super.init(
            type: .unknown,
            spacing: nil,
            height: nil,
            targetWidth: nil,
            separator: nil,
            isVisible: true,
            areaGridName: nil,
            id: nil
        )
        // We intentionally do not assign additionalProperties here,
        // so that toJSON() relies solely on originalJSON.
    }
    
    override func toJSON() -> [String: Any] {
        // Return the original JSON exactly.
        return originalJSON
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        // Encode each key/value pair from our toJSON() result.
        for (key, value) in self.toJSON() {
            let dynamicKey = DynamicCodingKey(stringValue: key)!
            if let stringValue = value as? String {
                try container.encode(stringValue, forKey: dynamicKey)
            } else if let intValue = value as? Int {
                try container.encode(intValue, forKey: dynamicKey)
            } else if let doubleValue = value as? Double {
                try container.encode(doubleValue, forKey: dynamicKey)
            } else if let boolValue = value as? Bool {
                try container.encode(boolValue, forKey: dynamicKey)
            } else {
                // Fallback: encode the JSON representation as a string.
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                let str = String(data: data, encoding: .utf8)
                try container.encode(str, forKey: dynamicKey)
            }
        }
    }
    
    /// Serializes the UnknownElement into a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        var json = (self.additionalProperties ?? [:]).mapValues { $0.value }
        json["type"] = elementType
        return ParseUtil.unwrapAnyCodable(from: json) as! [String: Any]
    }
    
    /// Converts the UnknownElement to a JSON string.
    func serialize() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: serializeToJson(), options: [.sortedKeys]) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    static func createFromJSON(_ json: [String: Any]) throws -> UnknownElement {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(UnknownElement.self, from: data)
    }
    
    /// Creates an UnknownElement object from a JSON string.
    static func createFromJSONString(_ jsonString: String) throws -> UnknownElement {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(UnknownElement.self, from: data)
    }
}

/// Parses UnknownElement elements in an Adaptive Card.
class UnknownElementParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        return try UnknownElement.createFromJSON(value)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        return try UnknownElement.createFromJSONString(value)
    }
}
