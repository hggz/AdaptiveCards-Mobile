import Foundation

/// Represents an OpenUrl action element in an adaptive card.
class SwiftOpenUrlAction: SwiftBaseActionElement {
    var url: String

    /// Designated initializer.
    init(
        url: String,
        title: String? = nil,
        iconUrl: String? = nil,
        tooltip: String? = nil,
        style: String? = "default",
        mode: SwiftMode = .primary,
        isEnabled: Bool = true,
        role: SwiftActionRole? = nil,
        id: String? = nil
    ) {
        self.url = url
        // Call the BaseActionElement initializer with the action type .openUrl.
        super.init(
            type: .openUrl,
            id: id
        )
    }

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case url
    }

    /// Decodes properties from the given decoder.
    required init(from decoder: Decoder) throws {
        // Decode OpenUrlAction-specific properties.
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        // Decode the rest of the properties via the superclass.
        try super.init(from: decoder)
    }

    /// Encodes properties to the given encoder.
    override func encode(to encoder: Encoder) throws {
        // First encode properties from the superclass.
        try super.encode(to: encoder)
        // Then encode OpenUrlAction-specific properties.
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
    }

    // MARK: - JSON Serialization Helpers

    /// Serializes `OpenUrlAction` to a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        // You can optionally merge in BaseActionElement’s JSON, if needed.
        var dict: [String: Any] = [
            "url": url,
            "type": typeString // for example, include the action type
        ]
        dict["title"] = title
        // Add additional base properties as needed.
        return dict
    }
}

/// Parses `OpenUrlAction` elements from JSON.
struct OpenUrlActionParser: SwiftActionElementParser {
    func deserialize(context: SwiftParseContext, from json: [String : Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftOpenUrlAction.make(from: json)
    }
    
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        let dict = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: dict)
    }
}

extension SwiftOpenUrlAction {
    static func make(from json: [String: Any]) throws -> SwiftOpenUrlAction {
        // parse "url"
        guard let url = json["url"] as? String else {
            throw SwiftAdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "url")
        }
        let title = json["title"] as? String
        let iconUrl = json["iconUrl"] as? String
        let style = json["style"] as? String ?? "default"
        let tooltip = json["tooltip"] as? String
        let mode = (json["mode"] as? String).flatMap { SwiftMode(rawValue: $0) } ?? .primary
        let isEnabled = json["isEnabled"] as? Bool ?? true

        // "actionRole" can also be read if present
        let roleString = json["actionRole"] as? String
        let role: SwiftActionRole = roleString.flatMap { SwiftActionRole(rawValue: $0) } ?? .link
        let id = json["id"] as? String

        return SwiftOpenUrlAction(url: url,
                             title: title,
                             iconUrl: iconUrl,
                             tooltip: tooltip,
                             style: style,
                             mode: mode,
                             isEnabled: isEnabled,
                             role: role,
                             id: id)
    }
}
