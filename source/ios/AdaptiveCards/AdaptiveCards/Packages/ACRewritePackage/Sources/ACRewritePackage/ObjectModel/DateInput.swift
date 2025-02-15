import Foundation

/// Represents a date input element in an Adaptive Card.
class DateInput: BaseInputElement {
    var max: String?
    var min: String?
    var placeholder: String?
    var value: String?
    
    /// Designated initializer.
    init(id: String? = nil,
         max: String? = nil,
         min: String? = nil,
         placeholder: String? = nil,
         value: String? = nil) {
        self.max = max
        self.min = min
        self.placeholder = placeholder
        self.value = value
        // Set type to .dateInput (ensure CardElementType includes this case)
        super.init(type: .dateInput, id: id)
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case max, min, placeholder, value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.max = try container.decodeIfPresent(String.self, forKey: .max)
        self.min = try container.decodeIfPresent(String.self, forKey: .min)
        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
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
    
    // Helper methods for manual JSON serialization/deserialization.
    override func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        if let max = max { json["max"] = max }
        if let min = min { json["min"] = min }
        if let placeholder = placeholder { json["placeholder"] = placeholder }
        if let value = value { json["value"] = value }
        return json
    }
    
    func toJSONString() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: toJSON(), options: .prettyPrinted)
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
    
    static func fromJSONString(_ jsonString: String) -> BaseCardElement? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
        return fromJSON(jsonDict)
    }
}


/// Parses DateInput elements in an Adaptive Card.
class DateInputParser: BaseCardElementParser {
    func deserialize(context: inout ParseContext, value: [String : Any]) throws -> BaseCardElement {
        guard let dateInput = DateInput.fromJSON(value) else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid DateInput JSON")
        }
        return dateInput
    }
    
    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        guard let dateInput = DateInput.fromJSONString(value) else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid DateInput JSON string")
        }
        return dateInput
    }
}
