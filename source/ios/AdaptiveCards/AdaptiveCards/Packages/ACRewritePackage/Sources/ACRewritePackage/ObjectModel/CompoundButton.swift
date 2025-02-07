import Foundation

struct CompoundButton: Codable {
    var badge: String?
    var title: String?
    var description: String?
    var icon: IconInfo?
    var selectAction: BaseActionElement?

    init(
        badge: String? = nil,
        title: String? = nil,
        description: String? = nil,
        icon: IconInfo? = nil,
        selectAction: BaseActionElement? = nil
    ) {
        self.badge = badge
        self.title = title
        self.description = description
        self.icon = icon
        self.selectAction = selectAction
    }

    // Serialization to JSON
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]

        if let badge = badge {
            json["badge"] = badge
        }

        if let title = title {
            json["title"] = title
        }

        if let description = description {
            json["description"] = description
        }

        if let icon = icon {
            json["icon"] = icon.toJSON()
        }

        if let action = selectAction {
            json["selectAction"] = action.toJSON()
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
    static func fromJSON(_ json: [String: Any]) -> CompoundButton? {
        guard !json.isEmpty else { return nil }

        return CompoundButton(
            badge: json["badge"] as? String,
            title: json["title"] as? String,
            description: json["description"] as? String,
            icon: (json["icon"] as? [String: Any]).flatMap { IconInfo.fromJSON($0) },
            selectAction: (json["selectAction"] as? [String: Any]).flatMap { try? BaseActionElement.deserialize(from: $0) }
        )
    }

    static func fromJSONString(_ jsonString: String) -> CompoundButton? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
        return fromJSON(jsonDict)
    }
}
