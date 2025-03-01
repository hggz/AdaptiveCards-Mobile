import Foundation

/// Represents a FactSet element in an Adaptive Card.
class SwiftFactSet: SwiftBaseCardElement {
    var facts: [SwiftFact]
    
    init(facts: [SwiftFact] = [], id: String? = nil) {
        self.facts = facts
        super.init(type: .factSet, id: id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case facts
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.facts = try container.decodeIfPresent([SwiftFact].self, forKey: .facts) ?? []
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(facts, forKey: .facts)
        try super.encode(to: encoder)
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        // Add FactSet specific properties
        if !facts.isEmpty {
            json["facts"] = try facts.map { try $0.serializeToJsonValue() }
        }
        
        return json
    }
    
    // Static creation methods
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftFactSet {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftFactSet.self, from: data)
    }
    
    static func createFromJSONString(_ jsonString: String) throws -> SwiftFactSet {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(SwiftFactSet.self, from: data)
    }
}

// Update parser to match pattern
struct SwiftFactSetParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftFactSet.createFromJSON(value)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftFactSet.createFromJSONString(value)
    }
}
