import Foundation

/// Represents an ActionSet element in an Adaptive Card.
class ActionSet: BaseCardElement {
    var actions: [BaseActionElement]

    // MARK: - Initializers
    init(actions: [BaseActionElement] = [], id: String? = nil) {
        self.actions = actions
        // Initialize the BaseCardElement using the CardElementType.actionSet value.
        super.init(type: .actionSet, id: id)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode the type and verify that it is indeed "ActionSet".
        let typeRaw = try container.decode(String.self, forKey: .type)
        guard typeRaw == CardElementType.actionSet.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        self.actions = try container.decodeIfPresent([BaseActionElement].self, forKey: .actions) ?? []
        // Decode the rest of the properties from BaseCardElement.
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        // Encode the local properties.
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CardElementType.actionSet.rawValue, forKey: .type)
        try container.encode(actions, forKey: .actions)
        // Then encode the BaseCardElement properties.
        try super.encode(to: encoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case actions
    }
}

/// Parses ActionSet elements in an Adaptive Card.
struct ActionSetParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String : Any]) throws -> any AdaptiveCardElementProtocol {
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.actionSet.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        // Parse actions using the provided parsing utilities.
        let actions = try ParseUtil.getActionCollection(from: value, key: "actions")
        return ActionSet(actions: actions)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}
