import Foundation

struct Icon: Codable {
    var name: String?
    var foregroundColor: ForegroundColor
    var iconSize: IconSize
    var iconStyle: IconStyle
    var selectAction: BaseActionElement?

    init(
        name: String? = nil,
        foregroundColor: ForegroundColor = .default,
        iconSize: IconSize = .standard,
        iconStyle: IconStyle = .regular,
        selectAction: BaseActionElement? = nil
    ) {
        self.name = name
        self.foregroundColor = foregroundColor
        self.iconSize = iconSize
        self.iconStyle = iconStyle
        self.selectAction = selectAction
    }

    // Serialization to JSON
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]

        if iconSize != .standard {
            json["size"] = iconSize.rawValue
        }
        
        if iconStyle != .regular {
            json["style"] = iconStyle.rawValue
        }
        
        if foregroundColor != .default {
            json["color"] = foregroundColor.rawValue
        }
        
        if let name = name {
            json["name"] = name
        }
        
        if let selectAction = selectAction {
            json["selectAction"] = selectAction.toJSON()
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
    static func fromJSON(_ json: [String: Any]) -> Icon {
        return Icon(
            name: json["name"] as? String,
            foregroundColor: ForegroundColor(rawValue: json["color"] as? String ?? ForegroundColor.default.rawValue) ?? .default,
            iconSize: IconSize(rawValue: json["size"] as? String ?? IconSize.standard.rawValue) ?? .standard,
            iconStyle: IconStyle(rawValue: json["style"] as? String ?? IconStyle.regular.rawValue) ?? .regular,
            selectAction: try? BaseActionElement.deserialize(from: json["selectAction"] as? [String: Any] ?? [:])
        )
    }

    static func fromJSONString(_ jsonString: String) -> Icon? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
        return fromJSON(jsonDict)
    }

    // Get SVG Path
    func getSVGPath() -> String {
        guard let name = name else { return "" }
        return "\(name)/\(name).json"
    }
}

enum IconSize: String, Codable {
    case standard = "standard"
    case small = "small"
    case medium = "medium"
    case large = "large"
}

enum IconStyle: String, Codable {
    case regular = "regular"
    case outlined = "outlined"
    case filled = "filled"
}

// Icon Parser
struct IconParser {
    static func deserialize(from json: [String: Any]) -> Icon {
        return Icon.fromJSON(json)
    }

    static func deserialize(from jsonString: String) -> Icon? {
        return Icon.fromJSONString(jsonString)
    }
}
