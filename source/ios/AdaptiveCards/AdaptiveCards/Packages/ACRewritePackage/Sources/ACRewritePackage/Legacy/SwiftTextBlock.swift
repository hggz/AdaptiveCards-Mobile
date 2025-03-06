import Foundation

// MARK: - TextBlock Implementation

/// Represents a TextBlock element in an Adaptive Card.
class TextBlock: SwiftBaseCardElement {
    // MARK: - Properties
    
    var text: String
    let textStyle: SwiftTextStyle?
    let textSize: SwiftTextSize?
    let textWeight: SwiftTextWeight?
    var fontType: SwiftFontType?
    let textColor: SwiftForegroundColor?
    let isSubtle: Bool?
    let wrap: Bool
    let maxLines: UInt
    let horizontalAlignment: SwiftHorizontalAlignment?
    let language: String?

    // MARK: - Initializers
    
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
    
    // MARK: - Codable Implementation
    
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
    
    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        let rawText = try container.decode(String.self, forKey: .text)
        text = TextBlock.decodeHTMLEntities(rawText)
        
        // Handle text style with custom decoding logic
        if let styleStr = try? container.decodeIfPresent(String.self, forKey: .textStyle) {
            switch styleStr.lowercased() {
            case "heading":
                textStyle = .heading
            case "default":
                textStyle = .defaultStyle
            default:
                textStyle = nil
            }
        } else {
            textStyle = nil
        }
        
        // Decode remaining properties
        textSize = try container.decodeIfPresent(SwiftTextSize.self, forKey: .textSize)
        textWeight = try container.decodeIfPresent(SwiftTextWeight.self, forKey: .textWeight)
        fontType = try container.decodeIfPresent(SwiftFontType.self, forKey: .fontType)
        textColor = try container.decodeIfPresent(SwiftForegroundColor.self, forKey: .textColor)
        isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        maxLines = try container.decodeIfPresent(UInt.self, forKey: .maxLines) ?? 0
        horizontalAlignment = try container.decodeIfPresent(SwiftHorizontalAlignment.self, forKey: .horizontalAlignment)
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "en"
        
        // Decode the base class properties
        try super.init(from: decoder)
        
        // Remove known properties from additionalProperties
        cleanupAdditionalProperties()
    }

    /// Encodes the TextBlock to JSON.
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
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
    }
    
    // MARK: - Serialization to JSON
    
    /// Converts this TextBlock into a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    // MARK: - Helper Methods
    
    /// Returns a DateTimePreparser initialized with the current text.
    func getTextForDateParsing() -> SwiftDateTimePreparser {
        return SwiftDateTimePreparser(input: self.text)
    }
    
    /// Cleanup additional properties after deserialization
    private func cleanupAdditionalProperties() {
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
}
