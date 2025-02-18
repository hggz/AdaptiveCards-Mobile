import Foundation

final class UnknownAction: BaseActionElement {
    private var originalTypeString: String

    override var typeString: String {
        get {
            // Special case for "Action.Invalid"
            if originalTypeString == "Action.Invalid" {
                return ActionType.unknownAction.rawValue
            }
            return originalTypeString
        }
        set { originalTypeString = newValue }
    }
    
    init(type: String) {
        self.originalTypeString = type
        super.init(type: .unknownAction)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        // Get original type
        guard let typeKey = container.allKeys.first(where: { $0.stringValue == "type" }),
              let typeString = try? container.decode(String.self, forKey: typeKey) else {
            throw DecodingError.dataCorruptedError(forKey: .init(stringValue: "type")!,
                                                  in: container,
                                                  debugDescription: "Type is required")
        }
        self.originalTypeString = typeString
        
        // Decode all properties
        var properties = [String: AnyCodable]()
        for key in container.allKeys {
            properties[key.stringValue] = try container.decode(AnyCodable.self, forKey: key)
        }
        
        try super.init(type: .unknownAction)
        self.additionalProperties = properties
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        // Return all properties including type from additionalProperties
        return additionalProperties?.mapValues { $0.value } ?? [:]
    }
}

final class UnknownActionParser: ActionElementParser {
    func deserialize(context: ParseContext, from json: [String: Any]) throws -> any AdaptiveCardElementProtocol {
        guard let typeString = json["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        let unknownAction = UnknownAction(type: typeString)
        unknownAction.additionalProperties = json.mapValues { AnyCodable($0) }
        return unknownAction
    }
    
    func deserialize(fromString jsonString: String, context: ParseContext) throws -> any AdaptiveCardElementProtocol {
        let json = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: json)
    }
}
