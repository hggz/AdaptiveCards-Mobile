import Foundation

/// Represents a text block element with customizable properties.
struct TextBlock: Codable {
    var text: String
    var textStyle: TextStyle?
    var textSize: TextSize?
    var textWeight: TextWeight?
    var fontType: FontType?
    var textColor: ForegroundColor?
    var isSubtle: Bool?
    var wrap: Bool
    var maxLines: UInt
    var horizontalAlignment: HorizontalAlignment?
    var language: String?

    /// Default initializer
    init(
        text: String = "",
        textStyle: TextStyle? = nil,
        textSize: TextSize? = nil,
        textWeight: TextWeight? = nil,
        fontType: FontType? = nil,
        textColor: ForegroundColor? = nil,
        isSubtle: Bool? = nil,
        wrap: Bool = false,
        maxLines: UInt = 0,
        horizontalAlignment: HorizontalAlignment? = nil,
        language: String? = nil
    ) {
        self.text = text
        self.textStyle = textStyle
        self.textSize = textSize
        self.textWeight = textWeight
        self.fontType = fontType
        self.textColor = textColor
        self.isSubtle = isSubtle
        self.wrap = wrap
        self.maxLines = maxLines
        self.horizontalAlignment = horizontalAlignment
        self.language = language
    }

    /// Decodes a `TextBlock` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> TextBlock {
        let text = try ParseUtil.getString(json, key: .text)
        let textStyle = try ParseUtil.getOptionalEnumValue(json, key: .style, converter: TextStyle.init)
        let textSize = try ParseUtil.getOptionalEnumValue(json, key: .size, converter: TextSize.init)
        let textWeight = try ParseUtil.getOptionalEnumValue(json, key: .weight, converter: TextWeight.init)
        let fontType = try ParseUtil.getOptionalEnumValue(json, key: .fontType, converter: FontType.init)
        let textColor = try ParseUtil.getOptionalEnumValue(json, key: .color, converter: ForegroundColor.init)
        let isSubtle = try ParseUtil.getOptionalBool(json, key: .isSubtle)
        let wrap = try ParseUtil.getBool(json, key: .wrap, defaultValue: false)
        let maxLines = try ParseUtil.getUInt(json, key: .maxLines, defaultValue: 0)
        let horizontalAlignment = try ParseUtil.getOptionalEnumValue(json, key: .horizontalAlignment, converter: HorizontalAlignment.init)
        let language = try ParseUtil.getOptionalString(json, key: .language)

        return TextBlock(
            text: text,
            textStyle: textStyle,
            textSize: textSize,
            textWeight: textWeight,
            fontType: fontType,
            textColor: textColor,
            isSubtle: isSubtle,
            wrap: wrap,
            maxLines: maxLines,
            horizontalAlignment: horizontalAlignment,
            language: language
        )
    }

    /// Decodes a `TextBlock` from a JSON string.
    static func deserialize(from jsonString: String) throws -> TextBlock {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: json)
    }

    /// Encodes `TextBlock` to a JSON dictionary.
    func serializeToJsonValue() -> [String: Any] {
        var json: [String: Any] = [
            AdaptiveCardSchemaKey.text.rawValue: text,
            AdaptiveCardSchemaKey.wrap.rawValue: wrap,
            AdaptiveCardSchemaKey.maxLines.rawValue: maxLines
        ]

        if let textStyle = textStyle { json[AdaptiveCardSchemaKey.style.rawValue] = textStyle.rawValue }
        if let textSize = textSize { json[AdaptiveCardSchemaKey.size.rawValue] = textSize.rawValue }
        if let textWeight = textWeight { json[AdaptiveCardSchemaKey.weight.rawValue] = textWeight.rawValue }
        if let fontType = fontType { json[AdaptiveCardSchemaKey.fontType.rawValue] = fontType.rawValue }
        if let textColor = textColor { json[AdaptiveCardSchemaKey.color.rawValue] = textColor.rawValue }
        if let isSubtle = isSubtle { json[AdaptiveCardSchemaKey.isSubtle.rawValue] = isSubtle }
        if let horizontalAlignment = horizontalAlignment { json[AdaptiveCardSchemaKey.horizontalAlignment.rawValue] = horizontalAlignment.rawValue }
        if let language = language { json[AdaptiveCardSchemaKey.language.rawValue] = language }

        return json
    }

    /// Encodes `TextBlock` to a JSON string.
    func serialize() throws -> String {
        return try ParseUtil.jsonToString(serializeToJsonValue())
    }
}

/// Enum representing possible text styles.
enum TextStyle: String, Codable {
    case defaultStyle = "Default"
    case heading = "Heading"

    init(from rawValue: String) {
        self = TextStyle(rawValue: rawValue) ?? .defaultStyle
    }
}
