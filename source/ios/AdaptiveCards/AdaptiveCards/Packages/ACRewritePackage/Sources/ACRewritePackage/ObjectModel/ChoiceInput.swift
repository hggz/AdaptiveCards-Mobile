import Foundation

struct ChoiceInput: Codable {
    var title: String
    var value: String

    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case value = "Value"
    }

    func serializeToJson() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    static func deserialize(from json: [String: Any]) throws -> ChoiceInput {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(ChoiceInput.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> ChoiceInput {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ChoiceInput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(ChoiceInput.self, from: jsonData)
    }
}
