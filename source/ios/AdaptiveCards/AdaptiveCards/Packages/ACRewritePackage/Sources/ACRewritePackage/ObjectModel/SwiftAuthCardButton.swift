import Foundation

struct SwiftAuthCardButton: Codable {
    var type: String
    var title: String
    var image: String
    var value: String

    init(type: String = "", title: String = "", image: String = "", value: String = "") {
        self.type = type
        self.title = title
        self.image = image
        self.value = value
    }

    func shouldSerialize() -> Bool {
        return !type.isEmpty || !title.isEmpty || !image.isEmpty || !value.isEmpty
    }

    func serialize() -> String {
        let jsonData = try? JSONEncoder().encode(self)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    func serializeToJsonValue() -> [String: Any] {
        var json: [String: Any] = [:]

        if !type.isEmpty {
            json["type"] = type
        }
        if !title.isEmpty {
            json["title"] = title
        }
        if !image.isEmpty {
            json["image"] = image
        }
        if !value.isEmpty {
            json["value"] = value
        }

        return json
    }

    static func deserialize(from json: [String: Any]) -> SwiftAuthCardButton {
        return SwiftAuthCardButton(
            type: json["type"] as? String ?? "",
            title: json["title"] as? String ?? "",
            image: json["image"] as? String ?? "",
            value: json["value"] as? String ?? ""
        )
    }

    static func deserialize(from jsonString: String) -> SwiftAuthCardButton? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonDict)
    }
}
