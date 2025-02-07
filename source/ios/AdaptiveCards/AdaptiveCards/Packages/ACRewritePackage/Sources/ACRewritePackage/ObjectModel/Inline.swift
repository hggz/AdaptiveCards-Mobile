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
            return try? TextRun.deserialize(from: json)
        case .unknown:
            return nil
        }
    }
}
