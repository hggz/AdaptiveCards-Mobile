import Foundation

/// Represents a number input element in an Adaptive Card.
class NumberInput: BaseInputElement {
    var placeholder: String?
    var value: Double?
    var min: Double?
    var max: Double?

    /// Designated initializer.
    /// - Parameters:
    ///   - id: An optional identifier.
    ///   - placeholder: A placeholder string.
    ///   - value: The current value.
    ///   - min: The minimum allowed value.
    ///   - max: The maximum allowed value.
    ///   - spacing: Optional spacing (inherited from BaseCardElement).
    ///   - height: Optional height (inherited from BaseCardElement).
    ///   - targetWidth: Optional target width (inherited from BaseCardElement).
    ///   - separator: Optional separator flag (inherited from BaseCardElement).
    ///   - isVisible: Visibility flag (defaults to true).
    ///   - areaGridName: Optional grid area name.
    init(id: String? = nil,
         placeholder: String? = nil,
         value: Double? = nil,
         min: Double? = nil,
         max: Double? = nil,
         spacing: Spacing? = nil,
         height: HeightType? = nil,
         targetWidth: TargetWidthType? = nil,
         separator: Bool? = nil,
         isVisible: Bool = true,
         areaGridName: String? = nil) {
        
        self.placeholder = placeholder
        self.value = value
        self.min = min
        self.max = max
        
        // Assuming CardElementType has a case for numberInput.
        super.init(
            type: .numberInput,
            id: id, 
            spacing: spacing,
            height: height,
            targetWidth: targetWidth,
            separator: separator,
            isVisible: isVisible,
            areaGridName: areaGridName
        )
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case placeholder, value, min, max
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(Double.self, forKey: .value)
        self.min = try container.decodeIfPresent(Double.self, forKey: .min)
        self.max = try container.decodeIfPresent(Double.self, forKey: .max)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(max, forKey: .max)
        try super.encode(to: encoder)
    }
    
    // MARK: - JSON Serialization
    
    /// Converts the NumberInput object into a JSON dictionary.
    /// This adds the NumberInput–specific keys to those provided by BaseCardElement.
    func serializeToJson() -> [String: Any] {
        var json = [String: Any]()
        // Start with BaseCardElement serialization.
        if let baseJson = try? self.serializeToJsonValue() {
            json = baseJson
        }
        if let placeholder = placeholder {
            json["placeholder"] = placeholder
        }
        if let value = value {
            json["value"] = value
        }
        if let min = min {
            json["min"] = min
        }
        if let max = max {
            json["max"] = max
        }
        return json
    }
    
    /// Returns a JSON string representation.
    func toJSONString() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: serializeToJson(), options: .prettyPrinted)
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
    
    // MARK: - Utility Deserialization
    
    /// Creates a NumberInput object from a JSON dictionary.
    static func createFromJSON(_ json: [String: Any]) throws -> NumberInput {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(NumberInput.self, from: data)
    }
    
    /// Creates a NumberInput object from a JSON string.
    static func createFromJSONString(_ jsonString: String) throws -> NumberInput {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(NumberInput.self, from: data)
    }
}

/// Parses NumberInput elements in an Adaptive Card.
class NumberInputParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        return try NumberInput.createFromJSON(value)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        return try NumberInput.createFromJSONString(value)
    }
}
