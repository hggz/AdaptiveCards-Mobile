import Foundation

struct SwiftContentSource: Codable {
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

    func getResourceInformation() -> SwiftRemoteResourceInformation? {
        guard let url = url, let mimeType = mimeType else { return nil }
        return SwiftRemoteResourceInformation(url: url, mimeType: mimeType)
    }

    static func deserialize(from json: [String: Any]) throws -> SwiftContentSource {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftContentSource.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> SwiftContentSource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ContentSource", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(SwiftContentSource.self, from: jsonData)
    }
}
