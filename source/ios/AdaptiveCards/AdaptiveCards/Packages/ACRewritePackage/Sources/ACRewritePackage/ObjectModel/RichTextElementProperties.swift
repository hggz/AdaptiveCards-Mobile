import Foundation

/// Represents rich text element properties including formatting styles such as italic, strikethrough, and underline.
struct RichTextElementProperties: Codable {
    var text: String
    var textSize: TextSize?
    var textWeight: TextWeight?
    var fontType: FontType?
    var textColor: ForegroundColor?
    var isSubtle: Bool?
    var language: String
    var italic: Bool
    var strikethrough: Bool
    var underline: Bool

    init(
        text: String = "",
        textSize: TextSize? = nil,
        textWeight: TextWeight? = nil,
        fontType: FontType? = nil,
        textColor: ForegroundColor? = nil,
        isSubtle: Bool? = nil,
        language: String = "",
        italic: Bool = false,
        strikethrough: Bool = false,
        underline: Bool = false
    ) {
        self.text = Self.processHTMLEntities(text)
        self.textSize = textSize
        self.textWeight = textWeight
        self.fontType = fontType
        self.textColor = textColor
        self.isSubtle = isSubtle
        self.language = language
        self.italic = italic
        self.strikethrough = strikethrough
        self.underline = underline
    }

    /// Serializes the `RichTextElementProperties` to a JSON dictionary.
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
        json["italic"] = italic
        json["strikethrough"] = strikethrough
        json["underline"] = underline

        return json
    }

    /// Parses a `RichTextElementProperties` from a JSON dictionary.
    static func fromJSON(_ json: [String: Any]) throws -> RichTextElementProperties {
        guard let text = json["text"] as? String else {
            throw ParsingError.missingRequiredField("text")
        }

        let textSize = (json["size"] as? String).flatMap(TextSize.init)
        let textWeight = (json["weight"] as? String).flatMap(TextWeight.init)
        let fontType = (json["fontType"] as? String).flatMap(FontType.init)
        let textColor = (json["color"] as? String).flatMap(ForegroundColor.init)
        let isSubtle = json["isSubtle"] as? Bool
        let language = json["language"] as? String ?? ""
        let italic = json["italic"] as? Bool ?? false
        let strikethrough = json["strikethrough"] as? Bool ?? false
        let underline = json["underline"] as? Bool ?? false

        return RichTextElementProperties(
            text: text,
            textSize: textSize,
            textWeight: textWeight,
            fontType: fontType,
            textColor: textColor,
            isSubtle: isSubtle,
            language: language,
            italic: italic,
            strikethrough: strikethrough,
            underline: underline
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
