import Foundation

struct Container: Codable {
    var items: [BaseCardElement]
    var layouts: [Layout]
    var rtl: Bool?

    init(
        items: [BaseCardElement] = [],
        layouts: [Layout] = [],
        rtl: Bool? = nil
    ) {
        self.items = items
        self.layouts = layouts
        self.rtl = rtl
    }

    // Serialization to JSON
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]

        json["items"] = items.map { $0.toJSON() }
        json["layouts"] = layouts.map { $0.toJSON() }

        if let rtl = rtl {
            json["rtl"] = rtl
        }

        return json
    }

    func toJSONString() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: toJSON(), options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }

    // Deserialization
    static func fromJSON(_ json: [String: Any]) -> Container? {
        guard !json.isEmpty else { return nil }

        return Container(
            items: (json["items"] as? [[String: Any]])?.compactMap { BaseCardElement.fromJSON($0) } ?? [],
            layouts: (json["layouts"] as? [[String: Any]])?.compactMap { Layout.fromJSON($0) } ?? [],
            rtl: json["rtl"] as? Bool
        )
    }

    static func fromJSONString(_ jsonString: String) -> Container? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
        return fromJSON(jsonDict)
    }
}

class ContainerParser {
    static func deserialize(from json: [String: Any]) -> Container? {
        return Container.fromJSON(json)
    }

    static func deserialize(from jsonString: String) -> Container? {
        return Container.fromJSONString(jsonString)
    }
}
