import Foundation

/// Represents choices data in an Adaptive Card.
struct SwiftChoicesData: Codable {
    // MARK: - Properties
    let choicesDataType: String
    let dataset: String
    let associatedInputs: SwiftAssociatedInputs
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case choicesDataType = "ChoicesDataType"
        case dataset = "Dataset"
        case associatedInputs = "AssociatedInputs"
    }
}
