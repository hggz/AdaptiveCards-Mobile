import Foundation

struct SwiftFact: Codable {
    var title: String
    var value: String
    var language: String?

    enum CodingKeys: String, CodingKey {
        case title
        case value
        case language
    }

    init(title: String = "", value: String = "", language: String? = nil) {
        self.title = title
        self.value = value
        self.language = language
    }
    
    // Base serialization method
    func serializeToJsonValue() -> [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "value": value
        ]
        if let language = language {
            dict["language"] = language
        }
        return dict
    }
    
    // Other methods use serializeToJsonValue as base
    func serialize() -> String {
        let dict = serializeToJsonValue()
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
        return (String(data: data ?? Data(), encoding: .utf8) ?? "{}") + "\n"
    }
    
    func serializeWithType() -> [String: Any] {
        var dict = serializeToJsonValue()
        dict["type"] = "Fact"
        return dict
    }
    
    // Keep existing static deserialize methods
    static func deserialize(fromString jsonString: String, context: SwiftParseContext) -> SwiftFact? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        do {
            let fact = try JSONDecoder().decode(SwiftFact.self, from: data)
            return fact
        } catch {
            return nil
        }
    }
    
    static func deserialize(from json: [String: Any]) -> SwiftFact? {
        guard let title = json["title"] as? String,
              let value = json["value"] as? String else {
            return nil
        }
        let language = json["language"] as? String
        return SwiftFact(title: title, value: value, language: language)
    }
}
