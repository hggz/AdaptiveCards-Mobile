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
struct OpenUrlActionParser {
    /// Parses an `OpenUrlAction` object from JSON data.
    static func deserialize(from json: [String: Any]) throws -> OpenUrlAction {
        return try OpenUrlAction.deserialize(from: json)
    }

    /// Parses an `OpenUrlAction` object from a JSON string.
    static func deserialize(from jsonString: String) throws -> OpenUrlAction {
        return try OpenUrlAction.deserialize(from: jsonString)
    }
}
