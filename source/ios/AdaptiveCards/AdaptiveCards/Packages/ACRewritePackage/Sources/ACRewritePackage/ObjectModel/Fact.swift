import Foundation

struct Fact: Codable {
    var title: String
    var value: String
    var language: String?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case value = "value"
        case language = "language"
    }

    init(title: String = "", value: String = "", language: String? = nil) {
        self.title = title
        self.value = value
        self.language = language
    }

    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = [
            "title": title,
            "value": value
        ]
        if let language = language {
            json["language"] = language
        }
        return json
    }

    static func deserialize(from json: [String: Any]) -> Fact? {
        guard let title = json["title"] as? String, let value = json["value"] as? String else {
            return nil
        }
        let language = json["language"] as? String
        return Fact(title: title, value: value, language: language)
    }
}
