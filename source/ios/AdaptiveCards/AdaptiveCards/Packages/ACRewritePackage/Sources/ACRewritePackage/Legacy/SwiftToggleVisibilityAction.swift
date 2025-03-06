import Foundation

/// Represents an action to toggle visibility of elements in an Adaptive Card.
class SwiftToggleVisibilityAction: SwiftBaseActionElement {
    // MARK: - Properties
    var targetElements: [SwiftToggleVisibilityTarget]
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case targetElements
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targetElements = try container.decodeIfPresent([SwiftToggleVisibilityTarget].self, forKey: .targetElements) ?? []
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !targetElements.isEmpty {
            try container.encode(targetElements, forKey: .targetElements)
        }
    }
}
