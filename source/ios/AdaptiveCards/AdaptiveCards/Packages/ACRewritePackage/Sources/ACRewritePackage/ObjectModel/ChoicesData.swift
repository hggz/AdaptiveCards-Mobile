import Foundation

struct ChoicesData: Codable {
    var choicesDataType: String
    var dataset: String
    var associatedInputs: AssociatedInputs

    private enum CodingKeys: String, CodingKey {
        case choicesDataType = "ChoicesDataType"
        case dataset = "Dataset"
        case associatedInputs = "AssociatedInputs"
    }

    init(choicesDataType: String = "", dataset: String = "", associatedInputs: AssociatedInputs = .auto) {
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

    static func deserialize(from json: [String: Any]) throws -> ChoicesData {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(ChoicesData.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> ChoicesData {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ChoicesData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(ChoicesData.self, from: jsonData)
    }

    func shouldSerialize() -> Bool {
        return choicesDataType != "Data.Query" && !dataset.isEmpty
    }
}

enum AssociatedInputs: String, Codable {
    case auto = "Auto"
    case none = "None"
}
