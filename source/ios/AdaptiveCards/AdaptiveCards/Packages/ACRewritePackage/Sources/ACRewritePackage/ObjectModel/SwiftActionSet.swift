import Foundation

class SwiftActionSet: SwiftBaseCardElement {
    var actions: [SwiftBaseActionElement]

    // MARK: - Initializers
    init(actions: [SwiftBaseActionElement] = [], id: String? = nil) {
        self.actions = actions
        super.init(type: .actionSet, id: id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case actions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode actions array
        var actionsArray: [SwiftBaseActionElement] = []
        var actionsContainer = try container.nestedUnkeyedContainer(forKey: .actions)
        
        while !actionsContainer.isAtEnd {
            // Get the action as a dictionary first
            let actionDict = try actionsContainer.decode([String: AnyCodable].self)
            let dict = actionDict.mapValues { $0.value }
            
            // Use BaseActionElement's deserializeAction to get the correct type
            let action = try SwiftBaseActionElement.deserializeAction(from: dict)
            actionsArray.append(action)
        }
        
        self.actions = actionsArray
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actions, forKey: .actions)
        try super.encode(to: encoder)
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        json["type"] = "ActionSet"
        
        if !actions.isEmpty {
            json["actions"] = try actions.map { try $0.serializeToJsonValue() }
        }
        
        return json
    }
}

// Parser remains the same but uses decoder
struct SwiftActionSetParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        let data = try JSONSerialization.data(withJSONObject: value)
        return try JSONDecoder().decode(SwiftActionSet.self, from: data)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        guard let data = value.data(using: .utf8) else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try JSONDecoder().decode(SwiftActionSet.self, from: data)
    }
}
