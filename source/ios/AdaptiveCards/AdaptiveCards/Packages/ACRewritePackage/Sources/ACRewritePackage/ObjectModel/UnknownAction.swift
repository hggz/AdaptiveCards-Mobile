/// Represents an unknown action in Adaptive Cards.
import Foundation

/// Represents an unknown action in Adaptive Cards.
final class UnknownAction: BaseActionElement {
    /// Initializes an unknown action.
    init() {
        // Force the type to be .unknownAction.
        super.init(type: .unknownAction)
    }
    
    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        // Decode normally
        try super.init(from: decoder)
        // Force the typeString to the unknown action value.
        self.typeString = ActionType.unknownAction.rawValue
    }
    
    /// Override setElementTypeString to force the type to unknown.
    func setElementTypeString(_ type: String) {
        // Ignore the passed value and force the unknown type.
        self.typeString = ActionType.unknownAction.rawValue
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        // Return additionalProperties if set, or the base fields.
        return additionalProperties ?? [:]
    }
}

/// Parses an `UnknownAction` from JSON.
final class UnknownActionParser: ActionElementParser {
    func deserialize(context: ParseContext, from json: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        // Create an UnknownAction instance directly.
        let unknownAction = UnknownAction()
        // Force the type to unknown regardless of the JSON.
        unknownAction.setElementTypeString(try ParseUtil.getTypeAsString(from: json))
        return unknownAction
    }
    
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> any AdaptiveCardElementProtocol {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
    }
}
