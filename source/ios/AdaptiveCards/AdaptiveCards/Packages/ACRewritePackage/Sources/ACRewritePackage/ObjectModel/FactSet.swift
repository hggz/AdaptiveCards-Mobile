import Foundation

struct FactSet: Codable {
    var facts: [Fact]

    enum CodingKeys: String, CodingKey {
        case facts = "facts"
    }

    init(facts: [Fact] = []) {
        self.facts = facts
    }

    func serializeToJson() -> [String: Any] {
        return ["facts": facts.map { $0.serializeToJson() }]
    }

    static func deserialize(from json: [String: Any]) -> FactSet? {
        guard let factsArray = json["facts"] as? [[String: Any]] else {
            return nil
        }
        let facts = factsArray.compactMap { Fact.deserialize(from: $0) }
        return FactSet(facts: facts)
    }
}
