import Foundation

/// Represents a FactSet element in an Adaptive Card.
class FactSet: BaseCardElement {
    var facts: [Fact]
    
    init(facts: [Fact] = [], id: String? = nil) {
        self.facts = facts
        super.init(type: .factSet, id: id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case facts
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.facts = try container.decodeIfPresent([Fact].self, forKey: .facts) ?? []
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
    static func createFromJSON(_ json: [String: Any]) throws -> FactSet {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(FactSet.self, from: data)
    }
    
    static func createFromJSONString(_ jsonString: String) throws -> FactSet {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(FactSet.self, from: data)
    }
}

// Update parser to match pattern
struct FactSetParser: BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        return try FactSet.createFromJSON(value)
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> any AdaptiveCardElementProtocol {
        return try FactSet.createFromJSONString(value)
    }
}
