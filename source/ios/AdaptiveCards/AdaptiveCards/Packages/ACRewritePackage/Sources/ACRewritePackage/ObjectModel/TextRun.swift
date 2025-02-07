import Foundation

struct TextRun: Inline, Codable {
    let inlineType: InlineElementType = .textRun
    var additionalProperties: [String: AnyCodable] = [:]
    
    var text: String
    var textSize: TextSize?
    var textWeight: TextWeight?
    var fontType: FontType?
    var textColor: ForegroundColor?
    var isSubtle: Bool?
    var italic: Bool
    var strikethrough: Bool
    var highlight: Bool
    var underline: Bool
    var language: String?
    var selectAction: BaseActionElement?

    enum CodingKeys: String, CodingKey {
        case inlineType = "type"
        case text, textSize, textWeight, fontType, textColor, isSubtle, italic, strikethrough, highlight, underline, language, selectAction
    }

    func serializeToJson() -> [String: Any] {
        var json = additionalProperties.mapValues { $0.value }
        json["type"] = inlineType.rawValue
        json["text"] = text
        if let textSize = textSize { json["textSize"] = textSize.rawValue }
        if let textWeight = textWeight { json["textWeight"] = textWeight.rawValue }
        if let fontType = fontType { json["fontType"] = fontType.rawValue }
        if let textColor = textColor { json["textColor"] = textColor.rawValue }
        if let isSubtle = isSubtle { json["isSubtle"] = isSubtle }
        json["italic"] = italic
        json["strikethrough"] = strikethrough
        json["highlight"] = highlight
        json["underline"] = underline
        if let language = language { json["language"] = language }
        if let selectAction = selectAction { json["selectAction"] = selectAction.serializeToJson() }
        return json
    }

    static func deserialize(from json: [String: Any]) -> TextRun? {
        guard let text = json["text"] as? String else { return nil }

        var additionalProperties = json
        additionalProperties.removeValue(forKey: "type")
        additionalProperties.removeValue(forKey: "text")

        let textSize = (json["textSize"] as? String).flatMap { TextSize(rawValue: $0) }
        let textWeight = (json["textWeight"] as? String).flatMap { TextWeight(rawValue: $0) }
        let fontType = (json["fontType"] as? String).flatMap { FontType(rawValue: $0) }
        let textColor = (json["textColor"] as? String).flatMap { ForegroundColor(rawValue: $0) }
        let isSubtle = json["isSubtle"] as? Bool
        let italic = json["italic"] as? Bool ?? false
        let strikethrough = json["strikethrough"] as? Bool ?? false
        let highlight = json["highlight"] as? Bool ?? false
        let underline = json["underline"] as? Bool ?? false
        let language = json["language"] as? String
        let selectAction = (json["selectAction"] as? [String: Any]).flatMap { BaseActionElement.deserialize(from: $0) }

        return TextRun(
            additionalProperties: additionalProperties.mapValues { AnyCodable($0) },
            text: text,
            textSize: textSize,
            textWeight: textWeight,
            fontType: fontType,
            textColor: textColor,
            isSubtle: isSubtle,
            italic: italic,
            strikethrough: strikethrough,
            highlight: highlight,
            underline: underline,
            language: language,
            selectAction: selectAction
        )
    }
}
