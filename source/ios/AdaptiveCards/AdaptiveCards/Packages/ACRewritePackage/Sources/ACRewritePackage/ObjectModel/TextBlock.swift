import Foundation

// MARK: - Stubbed Types and Keys

/// Minimal stubs for text-related enums.
enum TextStyle: String, Codable {
    case defaultStyle = "Default"
    case heading = "Heading"
    
    init(from rawValue: String) {
        self = TextStyle(rawValue: rawValue) ?? .defaultStyle
    }
}

/// Represents a TextBlock element in an Adaptive Card.
class TextBlock: BaseCardElement {
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

    /// Designated initializer.
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
        language: String? = nil,
        id: String? = nil
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
        // Initialize BaseCardElement with the textBlock type.
        super.init(type: .textBlock, id: id)
    }
    
    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decode(String.self, forKey: .text)
        self.textStyle = try container.decodeIfPresent(TextStyle.self, forKey: .textStyle)
        self.textSize = try container.decodeIfPresent(TextSize.self, forKey: .textSize)
        self.textWeight = try container.decodeIfPresent(TextWeight.self, forKey: .textWeight)
        self.fontType = try container.decodeIfPresent(FontType.self, forKey: .fontType)
        self.textColor = try container.decodeIfPresent(ForegroundColor.self, forKey: .textColor)
        self.isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        self.wrap = try container.decode(Bool.self, forKey: .wrap)
        self.maxLines = try container.decode(UInt.self, forKey: .maxLines)
        self.horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment)
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
        try super.init(from: decoder)
    }
    
    /// Encodes the TextBlock to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(textStyle, forKey: .textStyle)
        try container.encodeIfPresent(textSize, forKey: .textSize)
        try container.encodeIfPresent(textWeight, forKey: .textWeight)
        try container.encodeIfPresent(fontType, forKey: .fontType)
        try container.encodeIfPresent(textColor, forKey: .textColor)
        try container.encodeIfPresent(isSubtle, forKey: .isSubtle)
        try container.encode(wrap, forKey: .wrap)
        try container.encode(maxLines, forKey: .maxLines)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        try container.encodeIfPresent(language, forKey: .language)
        try super.encode(to: encoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case text = "text"
        case textStyle = "style"
        case textSize = "size"
        case textWeight = "weight"
        case fontType = "fontType"
        case textColor = "color"
        case isSubtle = "isSubtle"
        case wrap = "wrap"
        case maxLines = "maxLines"
        case horizontalAlignment = "horizontalAlignment"
        case language = "language"
    }
    
    /// Converts this TextBlock into a JSON dictionary.
    func serializeToJsonVal() -> [String: Any] {
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
    
    /// Converts this TextBlock into a JSON string.
    func serialize() throws -> String {
        return try ParseUtil.jsonToString(serializeToJsonVal())
    }
}

/// Parses TextBlock elements in an Adaptive Card.
struct TextBlockParser: BaseCardElementParser {
    func deserialize(context: inout ParseContext, value: [String: Any]) throws -> BaseCardElement {
        // Verify the type.
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.textBlock.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        // Use the global deserialization helper (provided by BaseCardElement) and cast.
        guard let textBlock = try BaseCardElement.deserialize(from: value) as? TextBlock else {
            throw AdaptiveCardParseError.invalidType
        }
        return textBlock
    }
    
    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: &context, value: jsonDict)
    }
}
