import Foundation

/// Represents an ActionSet element in an Adaptive Card.
struct ActionSet: BaseCardElement, Codable {
    var type: CardElementType = .actionSet
    var actions: [BaseActionElement]
    
    // MARK: - Initializers
    init(actions: [BaseActionElement] = []) {
        self.actions = actions
    }

    // MARK: - Serialization
    enum CodingKeys: String, CodingKey {
        case type
        case actions
    }

    /// Encodes the ActionSet into JSON format.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(actions, forKey: .actions)
    }

    /// Decodes an ActionSet from JSON format.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(CardElementType.self, forKey: .type)
        self.actions = try container.decodeIfPresent([BaseActionElement].self, forKey: .actions) ?? []
    }
}

/// Parses ActionSet elements in an Adaptive Card.
struct ActionSetParser: BaseCardElementParser {
    
    /// Parses an `ActionSet` from a JSON dictionary.
    func deserialize(context: inout ParseContext, value: [String: Any]) throws -> BaseCardElement {
        guard let typeString = value["type"] as? String, typeString == CardElementType.actionSet.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }

        // Parse actions using the provided parsing utilities
        let actions = try ParseUtil.getActionCollection(context: &context, json: value, key: "actions")

        return ActionSet(actions: actions)
    }

    /// Parses an `ActionSet` from a JSON string.
    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        guard let jsonData = value.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }

        return try deserialize(context: &context, value: jsonDict)
    }
}
