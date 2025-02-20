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
    
    var unwrappedAdditionalProperties: [String: Any] {
        return additionalProperties.mapValues { $0.value }
    }
    
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
        if let selectAction = selectAction { json["selectAction"] = selectAction.toJSON()}
        return json
    }
    
    static func deserialize(from json: [String: Any]) throws -> TextRun? {
        guard let text = json["text"] as? String else { return nil }
        
        var additionalProperties = json
        additionalProperties.removeValue(forKey: "type")
        additionalProperties.removeValue(forKey: "text")
        additionalProperties.removeValue(forKey: "selectAction")
        additionalProperties.removeValue(forKey: "color")
        additionalProperties.removeValue(forKey: "size")
        additionalProperties.removeValue(forKey: "weight")
        
        // Map properties using AdaptiveCardSchemaKey-style mapping
        let textSize: TextSize?
        if let sizeString = json["textSize"] as? String {
            textSize = TextSize.fromString(sizeString)
        } else if let sizeString = json["size"] as? String {
            textSize = TextSize.fromString(sizeString)
        } else {
            textSize = nil
        }
        let textWeight = (json["weight"] as? String).flatMap { TextWeight(rawValue: $0) }
        let fontType = (json["fontType"] as? String).flatMap { FontType(rawValue: $0) }
        let textColor = (json["color"] as? String).flatMap { ForegroundColor.fromString($0) }
        let isSubtle = json["isSubtle"] as? Bool
        let italic = json["italic"] as? Bool ?? false
        let strikethrough = json["strikethrough"] as? Bool ?? false
        let highlight = json["highlight"] as? Bool ?? false
        let underline = json["underline"] as? Bool ?? false
        let language = json["lang"] as? String ?? "en" // Note: In C++ it uses "lang" key
        
        // Handle selectAction
        let selectAction: BaseActionElement?
        if let actionData = json["selectAction"] {
            if let dict = actionData as? [String: AnyCodable],
               let typeAnyCodable = dict["type"],
               let typeString = typeAnyCodable.value as? String {
                let actionDict: [String: Any] = ["type": typeString]
                selectAction = try BaseActionElement.deserializeAction(from: actionDict)
            } else {
                selectAction = nil
            }
        } else {
            selectAction = nil
        }
        
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
