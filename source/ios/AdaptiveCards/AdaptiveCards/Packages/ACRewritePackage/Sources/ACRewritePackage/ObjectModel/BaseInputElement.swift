import Foundation

struct BaseInputElement: Codable {
    var id: String
    var label: String?
    var isRequired: Bool
    var errorMessage: String?
    var valueChangedAction: ValueChangedAction?

    init(
        id: String = "",
        label: String? = nil,
        isRequired: Bool = false,
        errorMessage: String? = nil,
        valueChangedAction: ValueChangedAction? = nil
    ) {
        self.id = id
        self.label = label
        self.isRequired = isRequired
        self.errorMessage = errorMessage
        self.valueChangedAction = valueChangedAction
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case label
        case isRequired
        case errorMessage
        case valueChangedAction
    }

    func serialize() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    func shouldSerialize() -> Bool {
        return !id.isEmpty || isRequired || !(errorMessage?.isEmpty ?? true) || !(label?.isEmpty ?? true)
    }

    static func deserialize(from json: [String: Any]) throws -> BaseInputElement {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(BaseInputElement.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> BaseInputElement {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "BaseInputElement", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(BaseInputElement.self, from: jsonData)
    }
}
