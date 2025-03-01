import Foundation

/// MARK: - Separator Definition

/// Represents a separator with color and thickness attributes.
struct SwiftSeparator: Codable {
    var thickness: SwiftSeparatorThickness
    var color: SwiftForegroundColor

    /// Default initializer
    init(thickness: SwiftSeparatorThickness = .defaultThickness, color: SwiftForegroundColor = .default) {
        self.thickness = thickness
        self.color = color
    }

    /// Decodes a `Separator` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftSeparator {
        let color = try SwiftParseUtil.getEnumValue(from: json, key: SwiftAdaptiveCardSchemaKey.color.rawValue, defaultValue: SwiftForegroundColor.default, converter: SwiftForegroundColor.init)
        let thickness = try SwiftParseUtil.getEnumValue(from: json, key: SwiftAdaptiveCardSchemaKey.thickness.rawValue, defaultValue: SwiftSeparatorThickness.defaultThickness, converter: SwiftSeparatorThickness.init)
        return SwiftSeparator(thickness: thickness, color: color)
    }

    /// Decodes a `Separator` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftSeparator {
        let json = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: json)
    }

    /// Encodes `Separator` to a JSON dictionary.
    func serializeToJsonValue() -> [String: Any] {
        return [
            SwiftAdaptiveCardSchemaKey.color.rawValue: color.rawValue,
            SwiftAdaptiveCardSchemaKey.thickness.rawValue: thickness.rawValue
        ]
    }

    /// Encodes `Separator` to a JSON string.
    func serialize() throws -> String {
        return try SwiftParseUtil.jsonToString(serializeToJsonValue())
    }
}
