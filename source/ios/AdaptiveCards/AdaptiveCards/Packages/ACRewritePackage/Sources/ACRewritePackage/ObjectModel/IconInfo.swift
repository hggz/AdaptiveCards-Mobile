import Foundation

struct IconInfo: Codable {
    var name: String?
    var foregroundColor: ForegroundColor
    var iconSize: IconSize
    var iconStyle: IconStyle

    init(
        name: String? = nil,
        foregroundColor: ForegroundColor = .default,
        iconSize: IconSize = .standard,
        iconStyle: IconStyle = .regular
    ) {
        self.name = name
        self.foregroundColor = foregroundColor
        self.iconSize = iconSize
        self.iconStyle = iconStyle
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
    static func fromJSON(_ json: [String: Any]) -> IconInfo? {
        guard !json.isEmpty else { return nil }

        return IconInfo(
            name: json["name"] as? String,
            foregroundColor: ForegroundColor(rawValue: json["color"] as? String ?? ForegroundColor.default.rawValue) ?? .default,
            iconSize: IconSize(rawValue: json["size"] as? String ?? IconSize.standard.rawValue) ?? .standard,
            iconStyle: IconStyle(rawValue: json["style"] as? String ?? IconStyle.regular.rawValue) ?? .regular
        )
    }

    static func fromJSONString(_ jsonString: String) -> IconInfo? {
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
