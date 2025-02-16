import Foundation

/// Represents an unknown action in Adaptive Cards.
final class UnknownAction: BaseActionElement {
    /// Initializes an unknown action.
    init() {
        super.init(type: .unknownAction)
    }
    
    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    /// Serializes the unknown action into a JSON dictionary.
    /// Returns additionalProperties if set, or an empty dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        return additionalProperties ?? [:]
    }
}

/// Parses an `UnknownAction` from JSON.
final class UnknownActionParser: ActionElementParser {
    /// Deserializes an `UnknownAction` from a JSON dictionary.
    func deserialize(context: inout ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        let actualType = try ParseUtil.getTypeAsString(from: json)
        // Use the BaseActionElement deserialization method for actions.
        let base = try BaseActionElement.deserializeAction(from: json)
        guard let unknownAction = base as? UnknownAction else {
            throw AdaptiveCardParseError.invalidType
        }
        unknownAction.setAdditionalProperties(json)
        unknownAction.setElementTypeString(actualType)
        return unknownAction
    }
    
    /// Deserializes an `UnknownAction` from a JSON string.
    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: &context, from: json)
    }
}
