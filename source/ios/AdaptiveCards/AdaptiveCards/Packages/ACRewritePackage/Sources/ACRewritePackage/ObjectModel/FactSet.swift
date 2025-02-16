import Foundation

/// Represents a FactSet element in an Adaptive Card.
class FactSet: BaseCardElement {
    var facts: [Fact]

    /// Designated initializer.
    init(facts: [Fact] = [], id: String? = nil) {
        self.facts = facts
        // Initialize BaseCardElement with the appropriate card element type.
        super.init(type: .factSet, id: id)
    }

    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.facts = try container.decodeIfPresent([Fact].self, forKey: .facts) ?? []
        try super.init(from: decoder)
    }

    /// Encodes this FactSet.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(facts, forKey: .facts)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case facts
    }

    /// Returns a JSON dictionary representation.
    func serializeToJsonVal() -> [String: Any] {
        return ["facts": facts.map { $0.serialize() }]
    }
}

/// Parses FactSet elements in an Adaptive Card.
struct FactSetParser: BaseCardElementParser {
    func deserialize(context: inout ParseContext, value: [String: Any]) throws -> BaseCardElement {
        guard let typeString = value["type"] as? String,
              typeString == CardElementType.factSet.rawValue else {
            throw AdaptiveCardParseError.invalidType
        }
        // Use the BaseCardElement deserialization helper and cast to FactSet.
        guard let factSet = try BaseCardElement.deserialize(from: value) as? FactSet else {
            throw AdaptiveCardParseError.invalidType
        }
        return factSet
    }
    
    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        let jsonDict = try ParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: &context, value: jsonDict)
    }
}
