import Foundation

// MARK: - Stubbed Types and Keys

// MARK: - TextBlock Implementation

/// Represents a TextBlock element in an Adaptive Card.
class TextBlock: SwiftBaseCardElement {
    var text: String
    var textStyle: SwiftTextStyle?
    var textSize: SwiftTextSize?
    var textWeight: SwiftTextWeight?
    var fontType: SwiftFontType?
    var textColor: SwiftForegroundColor?
    var isSubtle: Bool?
    var wrap: Bool
    var maxLines: UInt
    var horizontalAlignment: SwiftHorizontalAlignment?
    var language: String?

    /// Designated initializer.
    init(
        text: String = "",
        textStyle: SwiftTextStyle? = .defaultStyle,
        textSize: SwiftTextSize? = nil,
        textWeight: SwiftTextWeight? = nil,
        fontType: SwiftFontType? = nil,
        textColor: SwiftForegroundColor? = nil,
        isSubtle: Bool? = nil,
        wrap: Bool = false,
        maxLines: UInt = 0,
        horizontalAlignment: SwiftHorizontalAlignment? = nil,
        language: String? = "en",
        id: String? = nil
    ) {
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
        super.init(type: .textBlock, id: id ?? "") // Convert nil to empty string here
    }
    
    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawText = try container.decode(String.self, forKey: .text)
        self.text = TextBlock.decodeHTMLEntities(rawText)
        
        // Default to .defaultStyle if not present or invalid
        if let styleStr = try? container.decodeIfPresent(String.self, forKey: .textStyle) {
            switch styleStr.lowercased() {
            case "heading":
                self.textStyle = .heading
            case "default":
                self.textStyle = .defaultStyle
            default:
                self.textStyle = nil
            }
        } else {
            self.textStyle = nil
        }
        
        self.textSize = try container.decodeIfPresent(SwiftTextSize.self, forKey: .textSize)
        self.textWeight = try container.decodeIfPresent(SwiftTextWeight.self, forKey: .textWeight)
        self.fontType = try container.decodeIfPresent(SwiftFontType.self, forKey: .fontType)
        self.textColor = try container.decodeIfPresent(SwiftForegroundColor.self, forKey: .textColor)
        self.isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        self.wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        self.maxLines = try container.decodeIfPresent(UInt.self, forKey: .maxLines) ?? 0
        self.horizontalAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .horizontalAlignment)
        self.language = try container.decodeIfPresent(String.self, forKey: .language) ?? "en"
        
        // Decode the base class first - this will handle id, spacing, and other base properties
        try super.init(from: decoder)
        
        // After decoding, remove known properties from additionalProperties
        if var additional = self.additionalProperties {
            additional.removeValue(forKey: "type")
            additional.removeValue(forKey: "text")
            additional.removeValue(forKey: "style")
            additional.removeValue(forKey: "size")
            additional.removeValue(forKey: "weight")
            additional.removeValue(forKey: "fontType")
            additional.removeValue(forKey: "color")
            additional.removeValue(forKey: "isSubtle")
            additional.removeValue(forKey: "wrap")
            additional.removeValue(forKey: "maxLines")
            additional.removeValue(forKey: "horizontalAlignment")
            additional.removeValue(forKey: "lang")
            self.additionalProperties = additional
        }

        // Force empty string for id if nil
        if self.id == nil {
            self.id = ""
        }
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
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        json["type"] = "TextBlock"
        json["text"] = text
        
        // Only include id if it's non-nil and non-empty
        if let id = id, !id.isEmpty {
            json["id"] = id
        } else {
            // Remove id from json if it was added by super class
            json.removeValue(forKey: "id")
        }
        
        // Only include style if it differs from default
        if let textStyle = textStyle, textStyle != .defaultStyle {
            json[SwiftAdaptiveCardSchemaKey.style.rawValue] = textStyle.rawValue
        }
        
        // Only include language if it's not "en"
        if let language = language, language != "en" {
            json["lang"] = language
        }
        
        // Include other properties only if they have non-default values
        if let textSize = textSize {
            json[SwiftAdaptiveCardSchemaKey.size.rawValue] = textSize.rawValue
        }
        if let textWeight = textWeight {
            json[SwiftAdaptiveCardSchemaKey.weight.rawValue] = textWeight.rawValue
        }
        if let fontType = fontType {
            json[SwiftAdaptiveCardSchemaKey.fontType.rawValue] = fontType.rawValue
        }
        if let textColor = textColor {
            json[SwiftAdaptiveCardSchemaKey.color.rawValue] = textColor.serializedString
        }
        if let isSubtle = isSubtle {
            json[SwiftAdaptiveCardSchemaKey.isSubtle.rawValue] = isSubtle
        }
        if wrap {
            json[SwiftAdaptiveCardSchemaKey.wrap.rawValue] = wrap
        }
        if maxLines > 0 {
            json[SwiftAdaptiveCardSchemaKey.maxLines.rawValue] = maxLines
        }
        if let horizontalAlignment = horizontalAlignment {
            json[SwiftAdaptiveCardSchemaKey.horizontalAlignment.rawValue] = horizontalAlignment.rawValue
        }
        
        return json
    }

    /// Converts this TextBlock into a JSON string.
    override func serialize() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: serializeToJsonValue(), options: [.sortedKeys])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw AdaptiveCardParseError.serializationFailed
        }
        return jsonString + "\n"
    }
    
    /// Returns a DateTimePreparser initialized with the current text.
    func getTextForDateParsing() -> SwiftDateTimePreparser {
        return SwiftDateTimePreparser(input: self.text)
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
struct SwiftTextBlockParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        // Verify the type.
        guard let typeString = value["type"] as? String,
              typeString == SwiftCardElementType.textBlock.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Convert the JSON dictionary into Data.
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        
        // Decode a TextBlock directly using the type information.
        let textBlock = try decoder.decode(TextBlock.self, from: data)
        return textBlock
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
