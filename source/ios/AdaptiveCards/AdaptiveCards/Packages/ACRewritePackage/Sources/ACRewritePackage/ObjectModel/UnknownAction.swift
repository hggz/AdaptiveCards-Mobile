import Foundation

/// Represents an unknown action in Adaptive Cards.
final class UnknownAction: BaseActionElement {
    /// Initializes an unknown action.
    init() {
        super.init(type: .unknownAction)
    }

    /// Serializes the unknown action into a JSON dictionary.
    override func serializeToJsonValue() -> [String: Any] {
        return additionalProperties
    }
}

/// Parses an `UnknownAction` from JSON.
final class UnknownActionParser: ActionElementParser {
    /// Deserializes an `UnknownAction` from a JSON dictionary.
    static func deserialize(context: inout ParseContext, json: [String: Any]) -> UnknownAction {
        let actualType = ParseUtil.getTypeAsString(json: json)
        let unknownAction = BaseActionElement.deserialize(UnknownAction.self, context: &context, json: json)
        unknownAction.setAdditionalProperties(json)
        unknownAction.setElementTypeString(actualType)
        return unknownAction
    }

    /// Deserializes an `UnknownAction` from a JSON string.
    static func deserialize(from jsonString: String, context: inout ParseContext) throws -> UnknownAction {
        let json = try ParseUtil.getJsonValue(from: jsonString)
        return deserialize(context: &context, json: json)
    }
}
