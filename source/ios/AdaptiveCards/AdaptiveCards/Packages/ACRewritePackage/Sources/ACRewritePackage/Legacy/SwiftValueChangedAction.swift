import Foundation

struct SwiftValueChangedAction: Codable {
    // MARK: - Properties
    let targetInputIds: [String]
    let valueChangedActionType: SwiftValueChangedActionType
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case targetInputIds
        case valueChangedActionType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        targetInputIds = try container.decodeIfPresent([String].self, forKey: .targetInputIds) ?? []
        valueChangedActionType = try container.decodeIfPresent(SwiftValueChangedActionType.self, forKey: .valueChangedActionType) ?? .resetInputs
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(targetInputIds, forKey: .targetInputIds)
        try container.encode(valueChangedActionType, forKey: .valueChangedActionType)
    }
}
