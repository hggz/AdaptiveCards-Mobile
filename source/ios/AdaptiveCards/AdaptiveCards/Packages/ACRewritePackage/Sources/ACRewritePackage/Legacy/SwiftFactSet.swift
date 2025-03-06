import Foundation

/// Represents a FactSet element in an Adaptive Card.
class SwiftFactSet: SwiftBaseCardElement {
    // MARK: - Properties
    let facts: [SwiftFact]
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case facts
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode properties before super.init
        facts = try container.decodeIfPresent([SwiftFact].self, forKey: .facts) ?? []
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(facts, forKey: .facts)
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
