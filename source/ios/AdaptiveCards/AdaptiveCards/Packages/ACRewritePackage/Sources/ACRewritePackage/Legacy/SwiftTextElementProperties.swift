import Foundation

/// Represents text element properties including text content, styling, and formatting options.
struct SwiftTextElementProperties: Codable {
    // MARK: - Properties
    
    let text: String
    let textSize: SwiftTextSize?
    let textWeight: SwiftTextWeight?
    let fontType: SwiftFontType?
    let textColor: SwiftForegroundColor?
    let isSubtle: Bool?
    let language: String
    
    // MARK: - Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case text
        case textSize = "size"
        case textWeight = "weight"
        case fontType
        case textColor = "color"
        case isSubtle
        case language
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let rawText = try container.decode(String.self, forKey: .text)
        text = SwiftTextElementProperties.processHTMLEntities(rawText)
        
        textSize = try container.decodeIfPresent(SwiftTextSize.self, forKey: .textSize)
        textWeight = try container.decodeIfPresent(SwiftTextWeight.self, forKey: .textWeight)
        fontType = try container.decodeIfPresent(SwiftFontType.self, forKey: .fontType)
        textColor = try container.decodeIfPresent(SwiftForegroundColor.self, forKey: .textColor)
        isSubtle = try container.decodeIfPresent(Bool.self, forKey: .isSubtle)
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? ""
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
    }
    
    // MARK: - Serialization to JSON
    
    /// Serializes the `TextElementProperties` to a JSON dictionary.
    func toJSON() -> [String: Any] {
        return SwiftTextElementPropertiesLegacySupport.serializeToJson(self)
    }
    
    // MARK: - HTML Entity Processing
    
    /// Converts HTML entities in text to their respective characters.
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
