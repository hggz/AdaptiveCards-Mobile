import Foundation

/// Represents a number input element in an adaptive card.
struct NumberInput: Codable {
    var placeholder: String?
    var value: Double?
    var min: Double?
    var max: Double?

    init(placeholder: String? = nil, value: Double? = nil, min: Double? = nil, max: Double? = nil) {
        self.placeholder = placeholder
        self.value = value
        self.min = min
        self.max = max
    }

    /// Serializes `NumberInput` to a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = [:]

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

    /// Deserializes a `NumberInput` from JSON.
    static func deserialize(from json: [String: Any]) throws -> NumberInput {
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(NumberInput.self, from: jsonData)
    }

    /// Deserializes a `NumberInput` from a JSON string.
    static func deserialize(from jsonString: String) throws -> NumberInput {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(NumberInput.self, from: jsonData)
    }
}

/// Parses `NumberInput` elements from JSON.
struct NumberInputParser {
    /// Parses a `NumberInput` object from JSON data.
    static func deserialize(from json: [String: Any]) throws -> NumberInput {
        let placeholder = json["placeholder"] as? String
        let value = json["value"] as? Double
        let min = json["min"] as? Double
        let max = json["max"] as? Double

        return NumberInput(placeholder: placeholder, value: value, min: min, max: max)
    }

    /// Parses a `NumberInput` object from a JSON string.
    static func deserialize(from jsonString: String) throws -> NumberInput {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        guard let json = jsonObject else {
            throw NSError(domain: "Invalid JSON Format", code: 0, userInfo: nil)
        }
        return try deserialize(from: json)
    }
}
