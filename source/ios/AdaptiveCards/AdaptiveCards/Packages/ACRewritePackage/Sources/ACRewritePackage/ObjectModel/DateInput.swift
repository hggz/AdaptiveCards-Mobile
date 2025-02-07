import Foundation

struct DateInput: Codable {
    var max: String?
    var min: String?
    var placeholder: String?
    var value: String?

    init(max: String? = nil, min: String? = nil, placeholder: String? = nil, value: String? = nil) {
        self.max = max
        self.min = min
        self.placeholder = placeholder
        self.value = value
    }

    // Serialization to JSON
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]

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

    func toJSONString() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: toJSON(), options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }

    // Deserialization
    static func fromJSON(_ json: [String: Any]) -> DateInput? {
        guard !json.isEmpty else { return nil }

        return DateInput(
            max: json["max"] as? String,
            min: json["min"] as? String,
            placeholder: json["placeholder"] as? String,
            value: json["value"] as? String
        )
    }

    static func fromJSONString(_ jsonString: String) -> DateInput? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
        return fromJSON(jsonDict)
    }
}

class DateInputParser {
    static func deserialize(from json: [String: Any]) -> DateInput? {
        return DateInput.fromJSON(json)
    }

    static func deserialize(from jsonString: String) -> DateInput? {
        return DateInput.fromJSONString(jsonString)
    }
}
