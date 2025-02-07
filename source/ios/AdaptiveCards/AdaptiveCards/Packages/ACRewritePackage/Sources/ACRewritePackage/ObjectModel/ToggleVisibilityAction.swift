import Foundation

/// Represents an action to toggle visibility of elements in an Adaptive Card.
class ToggleVisibilityAction: BaseActionElement, Codable {
    /// The target elements whose visibility is toggled.
    var targetElements: [ToggleVisibilityTarget]

    /// Initializes a `ToggleVisibilityAction` with default values.
    override init() {
        self.targetElements = []
        super.init(actionType: .toggleVisibility)
    }

    /// Decodes a `ToggleVisibilityAction` from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targetElements = try container.decodeIfPresent([ToggleVisibilityTarget].self, forKey: .targetElements) ?? []
        super.init(actionType: .toggleVisibility)
    }

    /// Encodes a `ToggleVisibilityAction` to JSON.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !targetElements.isEmpty {
            try container.encode(targetElements, forKey: .targetElements)
        }
    }

    /// Deserializes a `ToggleVisibilityAction` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: inout ParseContext) throws -> ToggleVisibilityAction {
        let toggleVisibilityAction = ToggleVisibilityAction()
        toggleVisibilityAction.targetElements = try ParseUtil.getElementCollection(
            from: json,
            key: .targetElements,
            context: &context,
            elementType: ToggleVisibilityTarget.self
        )
        return toggleVisibilityAction
    }

    /// Deserializes a `ToggleVisibilityAction` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> ToggleVisibilityAction {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardError.invalidJson
        }
        return try deserialize(from: jsonDict, context: &context)
    }

    private enum CodingKeys: String, CodingKey {
        case targetElements
    }
}

/// Parses a `ToggleVisibilityAction` from JSON.
class ToggleVisibilityActionParser: ActionElementParser {
    /// Parses a `ToggleVisibilityAction` from JSON.
    static func deserialize(from json: [String: Any], context: inout ParseContext) throws -> BaseActionElement {
        return try ToggleVisibilityAction.deserialize(from: json, context: &context)
    }

    /// Parses a `ToggleVisibilityAction` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        return try ToggleVisibilityAction.deserialize(from: jsonString, context: &context)
    }
}
