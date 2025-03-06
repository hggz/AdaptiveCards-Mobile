import Foundation

/// Base class for layout implementations in an Adaptive Card.
class SwiftLayout: Codable {
    // MARK: - Properties
    var layoutContainerType: SwiftLayoutContainerType = .none
    var targetWidth: SwiftTargetWidthType = .default
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case layoutContainerType = "layout"
        case targetWidth
    }
    
    // MARK: - Initialization
    init() { }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        layoutContainerType = try container.decodeIfPresent(SwiftLayoutContainerType.self, forKey: .layoutContainerType) ?? .none
        targetWidth = try container.decodeIfPresent(SwiftTargetWidthType.self, forKey: .targetWidth) ?? .default
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if layoutContainerType != .stack {
            try container.encode(layoutContainerType, forKey: .layoutContainerType)
        }
        
        if targetWidth != .default {
            try container.encode(targetWidth, forKey: .targetWidth)
        }
    }
}
