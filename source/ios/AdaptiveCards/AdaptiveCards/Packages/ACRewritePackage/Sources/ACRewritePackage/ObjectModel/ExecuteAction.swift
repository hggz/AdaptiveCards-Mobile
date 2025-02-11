import Foundation

final class ExecuteAction: BaseActionElement {
    var dataJson: [String: Any]?
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
        super.init(actionType: .execute)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataJson = try container.decodeIfPresent([String: Any].self, forKey: .dataJson)
        self.verb = try container.decodeIfPresent(String.self, forKey: .verb) ?? ""
        self.associatedInputs = try container.decodeIfPresent(AssociatedInputs.self, forKey: .associatedInputs) ?? .auto
        self.conditionallyEnabled = try container.decodeIfPresent(Bool.self, forKey: .conditionallyEnabled) ?? false
        super.init(actionType: .execute)
    }

    func setDataJson(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return
        }
        self.dataJson = json
    }

    func serializeToJson() -> [String: Any] {
        var json = super.serializeToJson()

        if let dataJson = dataJson {
            json["data"] = dataJson
        }
        if !verb.isEmpty {
            json["verb"] = verb
        }
        if associatedInputs != .auto {
            json["associatedInputs"] = associatedInputs.rawValue
        }
        json["conditionallyEnabled"] = conditionallyEnabled

        return json
    }
}

final class ExecuteActionParser: ActionElementParser {
    func deserialize(context: inout ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        let executeAction = ExecuteAction()
        
        executeAction.dataJson = json["data"] as? [String: Any]
        executeAction.verb = json["verb"] as? String ?? ""
        executeAction.associatedInputs = AssociatedInputs(rawValue: json["associatedInputs"] as? String ?? "auto") ?? .auto
        executeAction.conditionallyEnabled = json["conditionallyEnabled"] as? Bool ?? false

        return executeAction
    }

    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(context: &context, from: json)
    }
}
