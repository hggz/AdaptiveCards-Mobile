import Foundation

/// Represents an unknown action in Adaptive Cards.
final class UnknownAction: BaseActionElement {
    /// Initializes an unknown action.
    init() {
        super.init(type: .unknownAction)
    }
    
    
    required init(from decoder: Decoder) throws {
        // This decodes "type", "title", "iconUrl", etc., from the base:
        try super.init(from: decoder)
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        // Return any stored additionalProperties or base fields
        var result = try super.serializeToJsonValue()
        // If you want the original unknown type in the output:
        // result["type"] = self.typeString  // or whatever
        return result
    }
}

/// Parses an `UnknownAction` from JSON.
final class UnknownActionParser: ActionElementParser {
    func deserialize(context: ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        let actualType = try ParseUtil.getTypeAsString(from: json)
        // do not call BaseActionElement.deserializeAction(...) or you loop
        // Instead, decode an UnknownAction directly:
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let unknownAction = try JSONDecoder().decode(UnknownAction.self, from: data)
        
        // No more guard that throws invalidType. Instead:
        unknownAction.setAdditionalProperties(json)
        unknownAction.setElementTypeString(actualType)
        return unknownAction
    }
    
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> BaseActionElement {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
    }
}
