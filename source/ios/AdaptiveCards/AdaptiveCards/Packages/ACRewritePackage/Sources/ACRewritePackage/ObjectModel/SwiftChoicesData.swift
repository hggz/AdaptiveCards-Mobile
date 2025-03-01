import Foundation

struct SwiftChoicesData: Codable {
    var choicesDataType: String
    var dataset: String
    var associatedInputs: SwiftAssociatedInputs

    private enum CodingKeys: String, CodingKey {
        case choicesDataType = "ChoicesDataType"
        case dataset = "Dataset"
        case associatedInputs = "AssociatedInputs"
    }

    init(choicesDataType: String = "", dataset: String = "", associatedInputs: SwiftAssociatedInputs = .auto) {
        self.choicesDataType = choicesDataType
        self.dataset = dataset
        self.associatedInputs = associatedInputs
    }

    func serializeToJson() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    static func deserialize(from json: [String: Any]) throws -> SwiftChoicesData {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(SwiftChoicesData.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> SwiftChoicesData {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ChoicesData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(SwiftChoicesData.self, from: jsonData)
    }

    func shouldSerialize() -> Bool {
        return choicesDataType != "Data.Query" && !dataset.isEmpty
    }
}
