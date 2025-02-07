import Foundation

struct ContentSource: Codable {
    var mimeType: String?
    var url: String?

    private enum CodingKeys: String, CodingKey {
        case mimeType = "MimeType"
        case url = "Url"
    }

    func serializeToJson() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    func getResourceInformation() -> RemoteResourceInformation? {
        guard let url = url else { return nil }
        return RemoteResourceInformation(url: url, mimeType: mimeType)
    }

    static func deserialize(from json: [String: Any]) throws -> ContentSource {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(ContentSource.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> ContentSource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ContentSource", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(ContentSource.self, from: jsonData)
    }
}

struct RemoteResourceInformation: Codable {
    var url: String
    var mimeType: String?
}
