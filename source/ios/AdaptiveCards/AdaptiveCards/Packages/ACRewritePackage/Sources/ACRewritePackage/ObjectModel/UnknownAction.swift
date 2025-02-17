import Foundation

/// Represents an unknown action in Adaptive Cards.
final class UnknownAction: BaseActionElement {
    /// Initializes an unknown action.
    init() {
        // Force the type to be .unknown
        super.init(type: .unknownAction)
    }
    
    required init(from decoder: Decoder) throws {
        // Use the custom initializer to ensure type remains unknown.
        try super.init(from: decoder)
        // Ensure that after decoding, the type is set to unknown.
        self.type = .unknown
        self.typeString = CardElementType.unknown.rawValue
    }
    
    /// Override setElementTypeString to force the type to unknown.
    override func setElementTypeString(_ type: String) {
        // Ignore the passed value and force the unknown type.
        self.typeString = CardElementType.unknown.rawValue
        self.type = .unknown
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        // Return additionalProperties if set, or the base fields.
        return additionalProperties ?? [:]
    }
}

/// Parses an `UnknownAction` from JSON.
final class UnknownActionParser: ActionElementParser {
    func deserialize(context: ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        // Instead of decoding with JSONDecoder, create an UnknownAction instance directly.
        let unknownAction = UnknownAction()
        unknownAction.setAdditionalProperties(json)
        // Force the type to unknown.
        unknownAction.setElementTypeString(try ParseUtil.getTypeAsString(from: json))
        return unknownAction
    }
    
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> BaseActionElement {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
    }
}
