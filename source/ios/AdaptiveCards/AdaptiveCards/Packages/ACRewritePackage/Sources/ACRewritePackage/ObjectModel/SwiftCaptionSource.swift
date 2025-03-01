import Foundation

struct SwiftCaptionSource: Codable {
    var mimeType: String?
    var url: String?
    var label: String?

    private enum CodingKeys: String, CodingKey {
        case mimeType = "MimeType"
        case url = "Url"
        case label = "Label"
    }

    func serializeToJson() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    static func deserialize(from json: [String: Any]) throws -> SwiftCaptionSource {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftCaptionSource.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> SwiftCaptionSource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "CaptionSource", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(SwiftCaptionSource.self, from: jsonData)
    }
}
