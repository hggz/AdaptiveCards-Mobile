import Foundation

/// Represents an action to toggle visibility of elements in an Adaptive Card.
class ToggleVisibilityAction: BaseActionElement {
    /// The target elements whose visibility is toggled.
    var targetElements: [ToggleVisibilityTarget]

    /// Initializes a `ToggleVisibilityAction` with default values.
    init() {
        self.targetElements = []
        // Assuming that ActionType has a case named `toggleVisibility`
        super.init(type: .toggleVisibility)
    }

    /// Decodes a `ToggleVisibilityAction` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targetElements = try container.decodeIfPresent([ToggleVisibilityTarget].self, forKey: .targetElements) ?? []
        try super.init(from: decoder)
    }

    /// Encodes a `ToggleVisibilityAction` to JSON.
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !targetElements.isEmpty {
            try container.encode(targetElements, forKey: .targetElements)
        }
    }

    /// Deserializes a `ToggleVisibilityAction` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: ParseContext) throws -> ToggleVisibilityAction {
        let toggleVisibilityAction = ToggleVisibilityAction()
        if let targetsArray = json["targetElements"] as? [[String: Any]] {
            toggleVisibilityAction.targetElements = try targetsArray.map {
                // Removed the extra context parameter here.
                try ToggleVisibilityTarget.deserialize(from: $0)
            }
        } else {
            toggleVisibilityAction.targetElements = []
        }
        return toggleVisibilityAction
    }

    /// Deserializes a `ToggleVisibilityAction` from a JSON string.
    static func deserialize(from jsonString: String, context: ParseContext) throws -> ToggleVisibilityAction {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserialize(from: jsonDict, context: context)
    }

    private enum CodingKeys: String, CodingKey {
        case targetElements
    }
}

/// Parses a `ToggleVisibilityAction` from JSON.
class ToggleVisibilityActionParser: ActionElementParser {
    func deserialize(context: ParseContext, from json: [String : Any]) throws -> any AdaptiveCardElementProtocol {
        return try ToggleVisibilityAction.deserialize(from: json, context: context)
    }
    
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> any AdaptiveCardElementProtocol {
        return try ToggleVisibilityAction.deserialize(from: jsonString, context: context)
    }
}
