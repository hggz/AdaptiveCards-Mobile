import Foundation

// MARK: - Stubbed Types and Keys

/// Minimal stubs for text-related enums.
enum TextStyle: String, Codable {
    case defaultStyle = "Default"
    case heading = "Heading"
    
    init(from rawValue: String) {
        self = TextStyle(rawValue: rawValue) ?? .defaultStyle
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        
        switch raw.lowercased() {
        case "default":
            self = .defaultStyle
        case "heading":
            self = .heading
        default:
            // If unknown, fall back to .defaultStyle:
            self = .defaultStyle
        }
    }
}

// MARK: - TextBlock Implementation

/// Represents a TextBlock element in an Adaptive Card.
class TextBlock: BaseCardElement {
    var text: String
    var textStyle: TextStyle = .defaultStyle
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
        textStyle: TextStyle = .defaultStyle,
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
        // Use the helper to decode HTML entities on initialization
        self.text = TextBlock.decodeHTMLEntities(text)
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
        // Decoding and then performing HTML decoding here if needed.
        let rawText = try container.decode(String.self, forKey: .text)
        self.text = TextBlock.decodeHTMLEntities(rawText)
        if container.contains(.textStyle) {
            let rawStyle = try container.decode(String.self, forKey: .textStyle)
            // Convert case-insensitively. If unknown => defaultStyle
            switch rawStyle.lowercased() {
            case "heading": self.textStyle = .heading
            case "default": self.textStyle = .defaultStyle
            default:
                self.textStyle = .defaultStyle
            }
        } else {
            self.textStyle = .defaultStyle
        }
        self.textSize = try container.decodeIfPresent(TextSize.self, forKey: .textSize)
        self.textWeight = try container.decodeIfPresent(TextWeight.self, forKey: .textWeight)
        self.fontType = try container.decodeIfPresent(FontType.self, forKey: .fontType)
        self.textColor = try container.decodeIfPresent(ForegroundColor.self, forKey: .textColor)
        self.isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        self.maxLines = try container.decodeIfPresent(UInt.self, forKey: .maxLines) ?? 0
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
            AdaptiveCardSchemaKey.type.rawValue: "TextBlock",
            AdaptiveCardSchemaKey.text.rawValue: text
        ]
        json[AdaptiveCardSchemaKey.style.rawValue] = textStyle.rawValue
        if let textSize = textSize { json[AdaptiveCardSchemaKey.size.rawValue] = textSize.rawValue }
        if let textWeight = textWeight { json[AdaptiveCardSchemaKey.weight.rawValue] = textWeight.rawValue }
        if let fontType = fontType { json[AdaptiveCardSchemaKey.fontType.rawValue] = fontType.rawValue }
        if let textColor = textColor { json[AdaptiveCardSchemaKey.color.rawValue] = textColor.rawValue }
        if let isSubtle = isSubtle { json[AdaptiveCardSchemaKey.isSubtle.rawValue] = isSubtle }
        if wrap != false { json[AdaptiveCardSchemaKey.wrap.rawValue] = wrap }
        if maxLines != 0 { json[AdaptiveCardSchemaKey.maxLines.rawValue] = maxLines }
        if let horizontalAlignment = horizontalAlignment { json[AdaptiveCardSchemaKey.horizontalAlignment.rawValue] = horizontalAlignment.rawValue }
        if let language = language { json[AdaptiveCardSchemaKey.language.rawValue] = language }
        
        return json
    }
    
    /// Converts this TextBlock into a JSON string.
    func serialize() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: serializeToJsonVal(), options: [.sortedKeys])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw AdaptiveCardParseError.serializationFailed
        }
        return jsonString + "\n"
    }
    
    /// Returns a DateTimePreparser initialized with the current text.
    func getTextForDateParsing() -> DateTimePreparser {
        return DateTimePreparser(input: self.text)
    }
}

// MARK: - Added Methods for Unit Test Compatibility

extension TextBlock {
    /// Sets the text after performing a single-pass HTML entity decode.
    func setText(_ newText: String) {
        self.text = TextBlock.decodeHTMLEntities(newText)
    }
    
    /// Returns the (decoded) text.
    func getText() -> String {
        return self.text
    }
    
    /// Decodes HTML entities in the provided string using a single pass.
    /// Supported entities: &amp;, &lt;, &gt;, &nbsp;
    static func decodeHTMLEntities(_ input: String) -> String {
        let pattern = "&([a-zA-Z]+);"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return input }
        let nsInput = input as NSString
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: nsInput.length))
        
        var result = ""
        var lastRangeEnd = 0
        
        for match in matches {
            let matchRange = match.range
            // Append text between last match and current match.
            result.append(nsInput.substring(with: NSRange(location: lastRangeEnd, length: matchRange.location - lastRangeEnd)))
            
            let entityName = nsInput.substring(with: match.range(at: 1))
            let replacement: String
            switch entityName {
            case "amp":
                replacement = "&"
            case "lt":
                replacement = "<"
            case "gt":
                replacement = ">"
            case "nbsp":
                replacement = "\u{00A0}"
            default:
                // Leave unsupported entities unchanged.
                replacement = nsInput.substring(with: matchRange)
            }
            
            result.append(replacement)
            lastRangeEnd = matchRange.location + matchRange.length
        }
        // Append any remaining text.
        result.append(nsInput.substring(from: lastRangeEnd))
        return result
    }
}

/// Parses TextBlock elements in an Adaptive Card.
struct TextBlockParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> BaseCardElement {
        // Verify the type.
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.textBlock.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Convert the JSON dictionary into Data.
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        
        // Decode a TextBlock directly using the type information.
        let textBlock = try decoder.decode(TextBlock.self, from: data)
        return textBlock
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> BaseCardElement {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
