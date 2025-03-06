import Foundation

/// Represents a set of actions in an Adaptive Card.
class SwiftActionSet: SwiftBaseCardElement {
    // MARK: - Properties
    var actions: [SwiftBaseActionElement]
    
    // MARK: - Codable Implementation
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
}
