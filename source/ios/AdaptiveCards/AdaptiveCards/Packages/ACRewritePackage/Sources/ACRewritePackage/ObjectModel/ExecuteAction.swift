import Foundation

/// Represents the execute action element.
final class ExecuteAction: BaseActionElement {
    var dataJson: [String: AnyCodable]?
    var verb: String
    var associatedInputs: AssociatedInputs
    var conditionallyEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case dataJson = "data"
        case verb
        case associatedInputs
        case conditionallyEnabled
    }

    init() {
        self.dataJson = nil
        self.verb = ""
        self.associatedInputs = .auto
        self.conditionallyEnabled = false
        // Use the correct parameter name "type" when calling the superclass initializer.
        super.init(type: .execute)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataJson = try container.decodeIfPresent([String: AnyCodable].self, forKey: .dataJson)
        self.verb = try container.decodeIfPresent(String.self, forKey: .verb) ?? ""
        self.associatedInputs = try container.decodeIfPresent(AssociatedInputs.self, forKey: .associatedInputs) ?? .auto
        self.conditionallyEnabled = try container.decodeIfPresent(Bool.self, forKey: .conditionallyEnabled) ?? false
        try super.init(from: decoder)
        
        // Filter out known keys so that additionalProperties is empty if nothing extra was provided.
        if var additional = self.additionalProperties {
            let knownKeys: Set<String> = [
                "data", "verb", "associatedInputs", "conditionallyEnabled",
                "title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"
            ]
            additional = additional.filter { !knownKeys.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(dataJson, forKey: .dataJson)
        try container.encode(verb, forKey: .verb)
        try container.encode(associatedInputs, forKey: .associatedInputs)
        try container.encode(conditionallyEnabled, forKey: .conditionallyEnabled)
    }

    /// Sets the `dataJson` property from a JSON string.
    func setDataJson(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return
        }
        // Convert [String: Any] into [String: AnyCodable]
        self.dataJson = jsonDict.mapValues { AnyCodable($0) }
    }

    /// Serializes the action into a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        do {
            var json = try super.serializeToJsonValue()
            
            if let dataJson = dataJson {
                // Convert [String: AnyCodable] to [String: Any] by extracting underlying values.
                json["data"] = dataJson.mapValues { $0.value }
            }
            if !verb.isEmpty {
                json["verb"] = verb
            }
            if associatedInputs != .auto {
                json["associatedInputs"] = associatedInputs.rawValue
            }
            json["conditionallyEnabled"] = conditionallyEnabled
            
            return json
        } catch {
            debugPrint("execute action error serializing to json")
            return [:]
        }
    }
}

/// Parses JSON dictionaries into ExecuteAction elements.
final class ExecuteActionParser: ActionElementParser {
    func deserialize(context: ParseContext, from json: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        let executeAction = ExecuteAction()
        
        if let data = json["data"] as? [String: Any] {
            executeAction.dataJson = data.mapValues { AnyCodable($0) }
        }
        executeAction.verb = json["verb"] as? String ?? ""
        if let associatedInputsStr = json["associatedInputs"] as? String {
            executeAction.associatedInputs = AssociatedInputs(rawValue: associatedInputsStr) ?? .auto
        } else {
            executeAction.associatedInputs = .auto
        }
        executeAction.conditionallyEnabled = json["conditionallyEnabled"] as? Bool ?? false

        return executeAction
    }

    func deserialize(fromString jsonString: String, context: ParseContext) throws -> any AdaptiveCardElementProtocol {
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(context: context, from: json)
    }
}
