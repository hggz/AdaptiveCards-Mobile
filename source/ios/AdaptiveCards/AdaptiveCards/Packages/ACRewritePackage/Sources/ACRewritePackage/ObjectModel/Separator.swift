import Foundation

/// Represents a separator with color and thickness attributes.
struct Separator: Codable {
    var thickness: SeparatorThickness
    var color: ForegroundColor

    /// Default initializer
    init(thickness: SeparatorThickness = .default, color: ForegroundColor = .default) {
        self.thickness = thickness
        self.color = color
    }

    /// Decodes a `Separator` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> Separator {
        let color = try ParseUtil.getEnumValue(json, key: .color, defaultValue: .default, converter: ForegroundColor.init)
        let thickness = try ParseUtil.getEnumValue(json, key: .thickness, defaultValue: .default, converter: SeparatorThickness.init)

        return Separator(thickness: thickness, color: color)
    }

    /// Decodes a `Separator` from a JSON string.
    static func deserialize(from jsonString: String) throws -> Separator {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: json)
    }

    /// Encodes `Separator` to a JSON dictionary.
    func serializeToJsonValue() -> [String: Any] {
        return [
            AdaptiveCardSchemaKey.color.rawValue: color.rawValue,
            AdaptiveCardSchemaKey.thickness.rawValue: thickness.rawValue
        ]
    }

    /// Encodes `Separator` to a JSON string.
    func serialize() throws -> String {
        return try ParseUtil.jsonToString(serializeToJsonValue())
    }
}

/// Enum representing possible separator thickness values.
enum SeparatorThickness: String, Codable {
    case defaultThickness = "Default"
    case thick = "Thick"

    init(from rawValue: String) {
        self = SeparatorThickness(rawValue: rawValue) ?? .defaultThickness
    }
}

/// Enum representing possible foreground colors.
enum ForegroundColor: String, Codable {
    case defaultColor = "Default"
    case dark = "Dark"
    case light = "Light"
    case accent = "Accent"
    case good = "Good"
    case warning = "Warning"
    case attention = "Attention"

    init(from rawValue: String) {
        self = ForegroundColor(rawValue: rawValue) ?? .defaultColor
    }
}

/// Utility class for JSON parsing.
struct ParseUtil {
    static func getEnumValue<T: RawRepresentable>(_ json: [String: Any], key: AdaptiveCardSchemaKey, defaultValue: T, converter: (String) -> T) throws -> T {
        guard let rawValue = json[key.rawValue] as? String else {
            return defaultValue
        }
        return converter(rawValue)
    }

    static func getJsonDictionary(from jsonString: String) throws -> [String: Any] {
        guard let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw ParseError.invalidJson
        }
        return json
    }

    static func jsonToString(_ dictionary: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw ParseError.serializationFailed
        }
        return jsonString
    }
}

/// Enum representing keys used in JSON parsing.
enum AdaptiveCardSchemaKey: String {
    case color = "color"
    case thickness = "thickness"
}

/// Errors that can occur during parsing.
enum ParseError: Error {
    case invalidJson
    case serializationFailed
}
