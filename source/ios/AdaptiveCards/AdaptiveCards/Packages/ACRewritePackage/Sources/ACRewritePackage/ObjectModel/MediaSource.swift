import Foundation

/// Represents a media source, inheriting properties from `ContentSource`.
struct MediaSource: Codable {
    var url: String
    var mimeType: String?

    init(url: String, mimeType: String? = nil) {
        self.url = url
        self.mimeType = mimeType
    }

    /// Deserialize a `MediaSource` from JSON.
    static func deserialize(from json: [String: Any]) throws -> MediaSource {
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(MediaSource.self, from: jsonData)
    }

    /// Deserialize a `MediaSource` from a JSON string.
    static func deserialize(from jsonString: String) throws -> MediaSource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(MediaSource.self, from: jsonData)
    }
    
    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = ["url": url]
        if let mimeType = mimeType {
            json["mimeType"] = mimeType
        }
        return json
    }
    
    func getResourceInformation() -> [RemoteResourceInformation] {
        return [RemoteResourceInformation(url: url, mimeType: mimeType ?? "unknown")]
    }
}
