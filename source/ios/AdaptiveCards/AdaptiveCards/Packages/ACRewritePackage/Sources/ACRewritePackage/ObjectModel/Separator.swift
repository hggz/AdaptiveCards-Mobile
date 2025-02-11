import Foundation

// MARK: - Stubbed Helper Types

/// Enum representing possible separator thickness values.
enum SeparatorThickness: String, Codable {
    case defaultThickness = "Default"
    case thick = "Thick"

    init(from rawValue: String) {
        self = SeparatorThickness(rawValue: rawValue) ?? .defaultThickness
    }
}

/// MARK: - Separator Definition

/// Represents a separator with color and thickness attributes.
struct Separator: Codable {
    var thickness: SeparatorThickness
    var color: ForegroundColor

    /// Default initializer
    init(thickness: SeparatorThickness = .defaultThickness, color: ForegroundColor = .default) {
        self.thickness = thickness
        self.color = color
    }

    /// Decodes a `Separator` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> Separator {
        let color = try ParseUtil.getEnumValue(from: json, key: AdaptiveCardSchemaKey.color.rawValue, defaultValue: ForegroundColor.default, converter: ForegroundColor.init)
        let thickness = try ParseUtil.getEnumValue(from: json, key: AdaptiveCardSchemaKey.thickness.rawValue, defaultValue: SeparatorThickness.defaultThickness, converter: SeparatorThickness.init)
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
