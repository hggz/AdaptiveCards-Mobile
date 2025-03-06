import Foundation

/// Represents rich text element properties including formatting styles such as italic, strikethrough, and underline.
struct SwiftRichTextElementProperties: Codable {
    // MARK: - Properties
    let text: String
    let textSize: SwiftTextSize?
    let textWeight: SwiftTextWeight?
    let fontType: SwiftFontType?
    let textColor: SwiftForegroundColor?
    let isSubtle: Bool?
    let language: String
    let italic: Bool
    let strikethrough: Bool
    let underline: Bool
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case text
        case textSize = "size"
        case textWeight = "weight"
        case fontType
        case textColor = "color"
        case isSubtle
        case language
        case italic
        case strikethrough
        case underline
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let rawText = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        text = Self.processHTMLEntities(rawText)
        textSize = try container.decodeIfPresent(SwiftTextSize.self, forKey: .textSize)
        textWeight = try container.decodeIfPresent(SwiftTextWeight.self, forKey: .textWeight)
        fontType = try container.decodeIfPresent(SwiftFontType.self, forKey: .fontType)
        textColor = try container.decodeIfPresent(SwiftForegroundColor.self, forKey: .textColor)
        isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? ""
        italic = try container.decodeIfPresent(Bool.self, forKey: .italic) ?? false
        strikethrough = try container.decodeIfPresent(Bool.self, forKey: .strikethrough) ?? false
        underline = try container.decodeIfPresent(Bool.self, forKey: .underline) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(textSize, forKey: .textSize)
        try container.encodeIfPresent(textWeight, forKey: .textWeight)
        try container.encodeIfPresent(fontType, forKey: .fontType)
        try container.encodeIfPresent(textColor, forKey: .textColor)
        try container.encodeIfPresent(isSubtle, forKey: .isSubtle)
        try container.encode(language, forKey: .language)
        try container.encode(italic, forKey: .italic)
        try container.encode(strikethrough, forKey: .strikethrough)
        try container.encode(underline, forKey: .underline)
    }
    
    // MARK: - HTML Entity Processing
    private static func processHTMLEntities(_ input: String) -> String {
        let replacements: [String: String] = [
            "&quot;": "\"",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " ",
            "&amp;": "&"
        ]
        
        var output = input
        for (entity, replacement) in replacements {
            output = output.replacingOccurrences(of: entity, with: replacement)
        }
        return output
    }
}
