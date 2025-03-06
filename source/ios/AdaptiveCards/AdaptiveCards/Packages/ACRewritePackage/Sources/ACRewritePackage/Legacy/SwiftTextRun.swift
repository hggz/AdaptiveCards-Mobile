import Foundation

/// Represents a text run element in an Adaptive Card
struct SwiftTextRun: Codable, SwiftInline {
    // MARK: - Properties
    let inlineType: SwiftInlineElementType = .textRun
    
    /// The text content of the text run
    let text: String
    
    /// Optional text size
    let textSize: SwiftTextSize?
    
    /// Optional text weight
    let textWeight: SwiftTextWeight?
    
    /// Optional font type
    let fontType: SwiftFontType?
    
    /// Optional text color
    let textColor: SwiftForegroundColor?
    
    /// Optional subtle text flag
    let isSubtle: Bool?
    
    /// Italic text flag
    let italic: Bool
    
    /// Strikethrough text flag
    let strikethrough: Bool
    
    /// Highlight text flag
    let highlight: Bool
    
    /// Underline text flag
    let underline: Bool
    
    /// Optional language
    let language: String?
    
    /// Optional select action
    let selectAction: SwiftBaseActionElement?
    
    /// Additional properties not explicitly defined
    var additionalProperties: [String: AnyCodable] = [:]
    
    // MARK: - Computed Properties
    
    /// Unwrapped additional properties
    var unwrappedAdditionalProperties: [String: Any] {
        return additionalProperties.mapValues { $0.value }
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case inlineType = "type"
        case text, textSize, textWeight, fontType, textColor,
             isSubtle, italic, strikethrough, highlight,
             underline, language, selectAction
        
        // Add any additional properties not in the predefined keys
        case additionalProperties
    }
    
    // MARK: - Initializers
    
    init(
        text: String,
        textSize: SwiftTextSize? = nil,
        textWeight: SwiftTextWeight? = nil,
        fontType: SwiftFontType? = nil,
        textColor: SwiftForegroundColor? = nil,
        isSubtle: Bool? = nil,
        italic: Bool = false,
        strikethrough: Bool = false,
        highlight: Bool = false,
        underline: Bool = false,
        language: String? = "en", // Default to "en"
        selectAction: SwiftBaseActionElement? = nil,
        additionalProperties: [String: AnyCodable] = [:]
    ) {
        self.text = text
        self.textSize = textSize
        self.textWeight = textWeight
        self.fontType = fontType
        self.textColor = textColor
        self.isSubtle = isSubtle
        self.italic = italic
        self.strikethrough = strikethrough
        self.highlight = highlight
        self.underline = underline
        self.language = language // Defaults to "en" if nil
        self.selectAction = selectAction
        self.additionalProperties = additionalProperties
    }
    
    // MARK: - Decoding
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required properties
        text = try container.decode(String.self, forKey: .text)
        
        // Decode optional properties
        textSize = try container.decodeIfPresent(SwiftTextSize.self, forKey: .textSize)
        textWeight = try container.decodeIfPresent(SwiftTextWeight.self, forKey: .textWeight)
        fontType = try container.decodeIfPresent(SwiftFontType.self, forKey: .fontType)
        textColor = try container.decodeIfPresent(SwiftForegroundColor.self, forKey: .textColor)
        isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        
        // Decode flags with default values
        italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? false
        strikethrough = try container.decodeIfPresent(Bool.self, forKey: .strikethrough) ?? false
        highlight = try container.decodeIfPresent(Bool.self, forKey: .highlight) ?? false
        underline = try container.decodeIfPresent(Bool.self, forKey: .underline) ?? false
        
        // Decode optional properties
        language = try container.decodeIfPresent(String.self, forKey: .language)
        selectAction = try container.decodeIfPresent(SwiftBaseActionElement.self, forKey: .selectAction)
        
        // Handle additional properties
        additionalProperties = [:]
        let allKeys = container.allKeys
        for key in allKeys {
            // Skip already decoded keys
            guard !CodingKeys.allCases.contains(key) else { continue }
            
            // Try to decode any additional properties
            if let value = try? container.decode(AnyCodable.self, forKey: key) {
                additionalProperties[key.stringValue] = value
            }
        }
    }
    
    // MARK: - Encoding
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode required properties
        try container.encode(text, forKey: .text)
        
        // Encode optional properties that are not nil
        try container.encodeIfPresent(textSize, forKey: .textSize)
        try container.encodeIfPresent(textWeight, forKey: .textWeight)
        try container.encodeIfPresent(fontType, forKey: .fontType)
        try container.encodeIfPresent(textColor, forKey: .textColor)
        try container.encodeIfPresent(isSubtle, forKey: .isSubtle)
        
        // Encode flags when true
        if italic { try container.encode(italic, forKey: .italic) }
        if strikethrough { try container.encode(strikethrough, forKey: .strikethrough) }
        if highlight { try container.encode(highlight, forKey: .highlight) }
        if underline { try container.encode(underline, forKey: .underline) }
        
        // Encode optional properties
        try container.encodeIfPresent(language, forKey: .language)
        try container.encodeIfPresent(selectAction, forKey: .selectAction)
        
        // Encode additional properties
        for (key, value) in additionalProperties {
            try? container.encode(value, forKey: CodingKeys(rawValue: key)!)
        }
    }
}
