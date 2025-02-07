import Foundation

/// Represents an OpenUrl action element in an adaptive card.
struct OpenUrlAction: Codable {
    var url: String
    
    init(url: String) {
        self.url = url
    }

    /// Serializes `OpenUrlAction` to a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        return ["url": url]
    }

    /// Deserializes an `OpenUrlAction` from JSON.
    static func deserialize(from json: [String: Any]) throws -> OpenUrlAction {
        guard let url = json["url"] as? String else {
            throw NSError(domain: "Invalid JSON: Missing 'url' field", code: 0, userInfo: nil)
        }
        return OpenUrlAction(url: url)
    }

    /// Deserializes an `OpenUrlAction` from a JSON string.
    static func deserialize(from jsonString: String) throws -> OpenUrlAction {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(OpenUrlAction.self, from: jsonData)
    }
}

/// Parses `OpenUrlAction` elements from JSON.
struct OpenUrlActionParser: ActionElementParser {
    func deserialize(context: inout ParseContext, from json: [String : Any]) throws -> BaseActionElement {
        return try OpenUrlAction.deserialize(from: jsonString)
    }
    
    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        return try OpenUrlAction.deserialize(from: json)
    }
}
