import Foundation

enum InlineElementType: String, Codable {
    case textRun = "TextRun"
    case unknown = "Unknown"
}

protocol Inline: Codable {
    var inlineType: InlineElementType { get }
    var additionalProperties: [String: AnyCodable] { get set }

    func serializeToJson() -> [String: Any]
    static func deserialize(from json: [String: Any]) -> Inline?
}

extension Inline {
    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = additionalProperties.mapValues { $0.value }
        json["type"] = inlineType.rawValue
        return json
    }

    static func deserialize(from json: [String: Any]) -> Inline? {
        guard let typeString = json["type"] as? String,
              let type = InlineElementType(rawValue: typeString) else {
            return nil
        }

        switch type {
        case .textRun:
            return TextRun.deserialize(from: json)
        case .unknown:
            return nil
        }
    }
}

struct TextRun: Inline {
    let inlineType: InlineElementType = .textRun
    var additionalProperties: [String: AnyCodable] = [:]
    var text: String

    enum CodingKeys: String, CodingKey {
        case inlineType = "type"
        case text
    }

    func serializeToJson() -> [String: Any] {
        var json = additionalProperties.mapValues { $0.value }
        json["type"] = inlineType.rawValue
        json["text"] = text
        return json
    }

    static func deserialize(from json: [String: Any]) -> TextRun? {
        guard let text = json["text"] as? String else {
            return nil
        }

        var additionalProperties = json
        additionalProperties.removeValue(forKey: "type")
        additionalProperties.removeValue(forKey: "text")

        return TextRun(additionalProperties: additionalProperties.mapValues { AnyCodable($0) }, text: text)
    }
}
