import Foundation

/// Represents an OpenUrl action element in an adaptive card.
class OpenUrlAction: BaseActionElement {
    var url: String

    /// Designated initializer.
    init(
        url: String,
        title: String? = nil,
        iconUrl: String? = nil,
        tooltip: String? = nil,
        style: String? = "default",
        mode: Mode = .primary,
        isEnabled: Bool = true,
        role: ActionRole? = nil,
        id: String? = nil
    ) {
        self.url = url
        // Call the BaseActionElement initializer with the action type .openUrl.
        super.init(
            type: .openUrl,
            title: title,
            iconUrl: iconUrl,
            style: style,
            tooltip: tooltip,
            mode: mode,
            isEnabled: isEnabled,
            role: role,
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
            "type": type.rawValue // for example, include the action type
        ]
        if let title = title {
            dict["title"] = title
        }
        // Add additional base properties as needed.
        return dict
    }
}

/// Parses `OpenUrlAction` elements from JSON.
struct OpenUrlActionParser: ActionElementParser {
    func deserialize(context: inout ParseContext, from json: [String : Any]) throws -> BaseActionElement {
        // Use the correct parameter name and return type.
        return try OpenUrlAction.deserializeAction(from: json)
    }
    
    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        // Use the correct parameter name.
        return try OpenUrlAction.deserializeAction(from: jsonString)
    }
}
