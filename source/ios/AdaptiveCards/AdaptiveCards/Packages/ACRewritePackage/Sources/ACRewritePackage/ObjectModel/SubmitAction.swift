import Foundation

/// Represents a Submit Action in an Adaptive Card.
class SubmitAction: BaseActionElement {
    var dataJson: [String: Any]?
    var associatedInputs: AssociatedInputs
    var conditionallyEnabled: Bool

    /// Initializes a `SubmitAction` with default values.
    init(dataJson: [String: Any]? = nil, 
         associatedInputs: AssociatedInputs = .auto, 
         conditionallyEnabled: Bool = false) {
        self.dataJson = dataJson
        self.associatedInputs = associatedInputs
        self.conditionallyEnabled = conditionallyEnabled
        super.init(actionType: .submit)
    }

    /// Serializes the action into a JSON dictionary.
    override func serializeToJsonValue() -> [String: Any] {
        var json = super.serializeToJsonValue()
        
        if let dataJson = dataJson {
            json[AdaptiveCardSchemaKey.data.rawValue] = dataJson
        }

        if associatedInputs != .auto {
            json[AdaptiveCardSchemaKey.associatedInputs.rawValue] = associatedInputs.rawValue
        }

        json[AdaptiveCardSchemaKey.conditionallyEnabled.rawValue] = conditionallyEnabled

        return json
    }

    /// Converts the action into a JSON string.
    func serialize() throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: serializeToJsonValue(), options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Deserializes a `SubmitAction` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SubmitAction {
        let dataJson = json[AdaptiveCardSchemaKey.data.rawValue] as? [String: Any]
        let associatedInputs = AssociatedInputs(rawValue: json[AdaptiveCardSchemaKey.associatedInputs.rawValue] as? String ?? "auto") ?? .auto
        let conditionallyEnabled = json[AdaptiveCardSchemaKey.conditionallyEnabled.rawValue] as? Bool ?? false

        return SubmitAction(dataJson: dataJson, associatedInputs: associatedInputs, conditionallyEnabled: conditionallyEnabled)
    }
}

/// Parses a `SubmitAction` from JSON.
class SubmitActionParser: ActionElementParser {
    override func deserialize(from json: [String: Any]) throws -> BaseActionElement {
        return try SubmitAction.deserialize(from: json)
    }

    override func deserialize(from jsonString: String) throws -> BaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardError.invalidJson
        }
        return try deserialize(from: jsonDict)
    }
}
