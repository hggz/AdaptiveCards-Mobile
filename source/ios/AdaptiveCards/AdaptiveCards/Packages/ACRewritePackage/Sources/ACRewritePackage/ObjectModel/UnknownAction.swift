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
        // If you want to decode any base properties (title, iconUrl, etc.)
        // you can do manual decoding or use a JSONDecoder.
        // For example, using JSONDecoder:

        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let unknownAction = try JSONDecoder().decode(UnknownAction.self, from: data)
        
        // Now store original JSON as additionalProperties,
        // so you preserve all fields.
        unknownAction.setAdditionalProperties(json)
        
        // If you'd like to record the original "type" the JSON had, do:
        if let typeStr = json["type"] as? String {
            unknownAction.setElementTypeString(typeStr)
        }
        
        return unknownAction
    }
    
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> BaseActionElement {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
    }
}
