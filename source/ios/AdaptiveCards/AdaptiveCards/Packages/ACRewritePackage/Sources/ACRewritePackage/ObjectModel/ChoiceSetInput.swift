import Foundation

struct ChoiceSetInput: Codable {
    var isMultiSelect: Bool
    var choiceSetStyle: ChoiceSetStyle
    var choices: [ChoiceInput]
    var choicesData: ChoicesData?
    var value: String
    var wrap: Bool
    var placeholder: String

    private enum CodingKeys: String, CodingKey {
        case isMultiSelect = "IsMultiSelect"
        case choiceSetStyle = "Style"
        case choices = "Choices"
        case choicesData = "ChoicesData"
        case value = "Value"
        case wrap = "Wrap"
        case placeholder = "Placeholder"
    }

    init(
        isMultiSelect: Bool = false,
        choiceSetStyle: ChoiceSetStyle = .compact,
        choices: [ChoiceInput] = [],
        choicesData: ChoicesData? = nil,
        value: String = "",
        wrap: Bool = false,
        placeholder: String = ""
    ) {
        self.isMultiSelect = isMultiSelect
        self.choiceSetStyle = choiceSetStyle
        self.choices = choices
        self.choicesData = choicesData
        self.value = value
        self.wrap = wrap
        self.placeholder = placeholder
    }

    func serializeToJson() -> String? {
        guard let jsonData = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }

    static func deserialize(from json: [String: Any]) throws -> ChoiceSetInput {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(ChoiceSetInput.self, from: jsonData)
    }

    static func deserialize(from jsonString: String) throws -> ChoiceSetInput {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "ChoiceSetInput", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
        }
        return try JSONDecoder().decode(ChoiceSetInput.self, from: jsonData)
    }
}
