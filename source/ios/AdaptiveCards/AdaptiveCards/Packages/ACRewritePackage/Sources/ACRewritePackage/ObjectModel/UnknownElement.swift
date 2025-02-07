import Foundation

struct UnknownElement: Codable {
    var elementType: String
    var additionalProperties: [String: AnyCodable]

    init(elementType: String, additionalProperties: [String: AnyCodable] = [:]) {
        self.elementType = elementType
        self.additionalProperties = additionalProperties
    }

    enum CodingKeys: String, CodingKey {
        case elementType = "type"
    }

    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = additionalProperties.mapValues { $0.value }
        json["type"] = elementType
        return json
    }

    func serialize() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: serializeToJson(), options: .prettyPrinted) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    static func deserialize(from json: [String: Any]) -> UnknownElement? {
        guard let elementType = json["type"] as? String else {
            return nil
        }

        var additionalProperties = json
        additionalProperties.removeValue(forKey: "type")

        return UnknownElement(elementType: elementType, additionalProperties: additionalProperties.mapValues { AnyCodable($0) })
    }

    static func deserialize(from jsonString: String) -> UnknownElement? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonObject)
    }
}

struct UnknownElementParser {
    static func deserialize(from json: [String: Any]) -> UnknownElement? {
        return UnknownElement.deserialize(from: json)
    }

    static func deserialize(from jsonString: String) -> UnknownElement? {
        return UnknownElement.deserialize(from: jsonString)
    }
}
