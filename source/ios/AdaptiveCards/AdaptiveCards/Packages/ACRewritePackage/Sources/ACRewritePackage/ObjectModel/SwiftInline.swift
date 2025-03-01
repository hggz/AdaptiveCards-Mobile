import Foundation

protocol SwiftInline: Codable {
    var inlineType: SwiftInlineElementType { get }
    var additionalProperties: [String: AnyCodable] { get set }

    func serializeToJson() -> [String: Any]
    static func deserialize(from json: [String: Any]) -> SwiftInline?
}

extension SwiftInline {
    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = additionalProperties.mapValues { $0.value }
        json["type"] = inlineType.rawValue
        return json
    }

    static func deserialize(from json: [String: Any]) -> SwiftInline? {
        guard let typeString = json["type"] as? String,
              let type = SwiftInlineElementType(rawValue: typeString) else {
            return nil
        }

        switch type {
        case .textRun:
            return try? SwiftTextRun.deserialize(from: json)
        }
    }
}
