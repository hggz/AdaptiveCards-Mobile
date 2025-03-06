import Foundation

/// Represents a refresh action in an adaptive card.
struct SwiftRefresh: Codable {
    // MARK: - Properties
    let action: SwiftBaseActionElement?
    let userIds: [String]
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case action, userIds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Deserialize action if present
        if container.contains(.action) {
            let actionDict = try container.decode([String: AnyCodable].self, forKey: .action)
            let dict = actionDict.mapValues { $0.value }
            action = try SwiftBaseActionElement.deserializeAction(from: dict)
        } else {
            action = nil
        }
        
        // Deserialize userIds
        userIds = try container.decodeIfPresent([String].self, forKey: .userIds) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode action if present
        if let action = action {
            try container.encode(AnyCodable(action.toJSON()), forKey: .action)
        }
        
        // Only encode userIds if not empty
        if !userIds.isEmpty {
            try container.encode(userIds, forKey: .userIds)
        }
    }
    
    // MARK: - Initialization with Default Values
    init(action: SwiftBaseActionElement? = nil, userIds: [String] = []) {
        self.action = action
        self.userIds = userIds
    }
    
    // MARK: - Serialization to JSON
    func serializeToJson() -> [String: Any] {
        return SwiftRefreshLegacySupport.serializeToJson(self)
    }
    
    // MARK: - Utility
    var shouldSerialize: Bool {
        return action != nil || !userIds.isEmpty
    }
}
