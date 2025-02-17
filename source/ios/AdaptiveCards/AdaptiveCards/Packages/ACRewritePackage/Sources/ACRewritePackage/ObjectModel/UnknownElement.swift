import Foundation

/// Represents an unknown element in Adaptive Cards.
class UnknownElement: BaseCardElement {
    /// The raw type string of the unknown element.
    var elementType: String

    // Note: Do not redeclare additionalProperties.
    // They are inherited from BaseElement as:
    // var additionalProperties: [String: AnyCodable]?
    
    // MARK: - Dynamic CodingKey Implementation
    struct DynamicCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? { return nil }
        
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }
    
    // MARK: - Designated Initializer
    init(id: String? = nil,
         elementType: String,
         additionalProperties: [String: AnyCodable] = [:],
         spacing: Spacing? = nil,
         height: HeightType? = nil,
         targetWidth: TargetWidthType? = nil,
         separator: Bool? = nil,
         isVisible: Bool = true,
         areaGridName: String? = nil) {
        
        self.elementType = elementType
        // Call the BaseCardElement initializer (which does not accept additionalProperties).
        super.init(
            type: .unknown,
            spacing: spacing,
            height: height,
            targetWidth: targetWidth,
            separator: separator,
            isVisible: isVisible,
            areaGridName: areaGridName,
            id: id
        )
        // Then set the additionalProperties on the inherited property.
        self.additionalProperties = additionalProperties
    }

    // MARK: - Codable Conformance
    
    required init(from decoder: Decoder) throws {
        // Set default values for our own properties.
        self.elementType = ""
        // Do not reinitialize additionalProperties; it will be set later.
        
        // First, decode BaseCardElement properties.
        try super.init(from: decoder)
        
        // Now use a dynamic container to capture all keys.
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        // Decode the known "type" key.
        let typeKey = DynamicCodingKey(stringValue: "type")!
        self.elementType = try container.decode(String.self, forKey: typeKey)
        
        // Capture any additional keys (skip "type").
        var additional = [String: AnyCodable]()
        for key in container.allKeys {
            if key.stringValue == "type" { continue }
            let value = try container.decode(AnyCodable.self, forKey: key)
            additional[key.stringValue] = value
        }
        // Assign to the inherited additionalProperties (which is optional).
        self.additionalProperties = additional
    }
    
    override func encode(to encoder: Encoder) throws {
        // First, let BaseCardElement encode its properties.
        try super.encode(to: encoder)
        // Then encode our additional properties using a dynamic container.
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        let typeKey = DynamicCodingKey(stringValue: "type")!
        try container.encode(elementType, forKey: typeKey)
        // Use additionalProperties from the base (or an empty dictionary if nil)
        let additional = self.additionalProperties ?? [:]
        for (key, value) in additional {
            let dynamicKey = DynamicCodingKey(stringValue: key)!
            try container.encode(value, forKey: dynamicKey)
        }
    }
    
    // MARK: - JSON Serialization Helpers
    
    /// Serializes the UnknownElement into a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        // Use additionalProperties from the base (or an empty dictionary if nil)
        var json = (self.additionalProperties ?? [:]).mapValues { $0.value }
        json["type"] = elementType
        return json
    }
    
    /// Converts the UnknownElement to a pretty-printed JSON string.
    func serialize() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: serializeToJson(), options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Creates an UnknownElement object from a JSON dictionary.
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
    func deserialize(context: ParseContext, value: [String: Any]) throws -> BaseCardElement {
        return try UnknownElement.createFromJSON(value)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> BaseCardElement {
        return try UnknownElement.createFromJSONString(value)
    }
}
