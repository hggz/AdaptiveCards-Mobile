import Foundation

/// Represents text element properties including text content, styling, and formatting options.
struct TextElementProperties: Codable {
    var text: String
    var textSize: TextSize?
    var textWeight: TextWeight?
    var fontType: FontType?
    var textColor: ForegroundColor?
    var isSubtle: Bool?
    var language: String

    init(
        text: String = "",
        textSize: TextSize? = nil,
        textWeight: TextWeight? = nil,
        fontType: FontType? = nil,
        textColor: ForegroundColor? = nil,
        isSubtle: Bool? = nil,
        language: String = ""
    ) {
        self.text = Self.processHTMLEntities(text)
        self.textSize = textSize
        self.textWeight = textWeight
        self.fontType = fontType
        self.textColor = textColor
        self.isSubtle = isSubtle
        self.language = language
    }

    /// Serializes the `TextElementProperties` to a JSON dictionary.
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]

        if let textSize = textSize {
            json["size"] = textSize.rawValue
        }
        if let textColor = textColor {
            json["color"] = textColor.rawValue
        }
        if let textWeight = textWeight {
            json["weight"] = textWeight.rawValue
        }
        if let fontType = fontType {
            json["fontType"] = fontType.rawValue
        }
        if let isSubtle = isSubtle {
            json["isSubtle"] = isSubtle
        }

        json["text"] = text
        json["language"] = language

        return json
    }

    /// Parses a `TextElementProperties` from a JSON dictionary.
    static func fromJSON(_ json: [String: Any]) throws -> TextElementProperties {
        guard let text = json["text"] as? String else {
            throw ParsingError.missingRequiredField("text")
        }

        let textSize = (json["size"] as? String).flatMap(TextSize.init)
        let textWeight = (json["weight"] as? String).flatMap(TextWeight.init)
        let fontType = (json["fontType"] as? String).flatMap(FontType.init)
        let textColor = (json["color"] as? String).flatMap(ForegroundColor.init)
        let isSubtle = json["isSubtle"] as? Bool
        let language = json["language"] as? String ?? ""

        return TextElementProperties(
            text: text,
            textSize: textSize,
            textWeight: textWeight,
            fontType: fontType,
            textColor: textColor,
            isSubtle: isSubtle,
            language: language
        )
    }

    /// Converts HTML entities in text to their respective characters.
    private static func processHTMLEntities(_ input: String) -> String {
        let replacements: [String: String] = [
            "&quot;": "\"",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " ",
            "&amp;": "&"
        ]

        var output = input
        for (entity, replacement) in replacements {
            output = output.replacingOccurrences(of: entity, with: replacement)
        }
        return output
    }
}
