import Foundation

enum ImageFillMode: String, Codable {
    case cover
}

struct BackgroundImage: Codable {
    var url: String
    var fillMode: ImageFillMode
    var horizontalAlignment: HorizontalAlignment
    var verticalAlignment: VerticalAlignment

    init(
        url: String = "",
        fillMode: ImageFillMode = .cover,
        horizontalAlignment: HorizontalAlignment = .left,
        verticalAlignment: VerticalAlignment = .top
    ) {
        self.url = url
        self.fillMode = fillMode
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
    }

    func shouldSerialize() -> Bool {
        return !url.isEmpty
    }

    func serialize() -> String {
        let jsonData = try? JSONEncoder().encode(self)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    func serializeToJsonValue() -> [String: Any] {
        if url.isEmpty { return [:] }

        // If only URL is present and all other values are default, return just the URL as a string
        if fillMode == .cover, horizontalAlignment == .left, verticalAlignment == .top {
            return ["url": url]
        }

        // Otherwise, return full JSON object
        return [
            "url": url,
            "fillMode": fillMode.rawValue,
            "horizontalAlignment": horizontalAlignment.rawValue,
            "verticalAlignment": verticalAlignment.rawValue
        ]
    }

    static func deserialize(from json: [String: Any]) -> BackgroundImage {
        if let url = json["url"] as? String {
            return BackgroundImage(url: url)
        }
        
        return BackgroundImage(
            url: json["url"] as? String ?? "",
            fillMode: ImageFillMode(rawValue: json["fillMode"] as? String ?? "cover") ?? .cover,
            horizontalAlignment: HorizontalAlignment(rawValue: json["horizontalAlignment"] as? String ?? "left") ?? .left,
            verticalAlignment: VerticalAlignment(rawValue: json["verticalAlignment"] as? String ?? "top") ?? .top
        )
    }

    static func deserialize(from jsonString: String) -> BackgroundImage? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonDict)
    }
}
