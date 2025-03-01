import Foundation

class SwiftUnknownElement: SwiftBaseCardElement {
    private var elementType: String
    
    override var typeString: String {
        get { return elementType }
        set { elementType = newValue }
    }
    
    init(id: String? = nil,
         elementType: String,
         additionalProperties: [String: AnyCodable] = [:]) {
        self.elementType = elementType
        super.init(
            type: .unknown,
            spacing: nil,
            height: nil,
            targetWidth: nil,
            separator: nil,
            isVisible: true,
            areaGridName: nil,
            id: id
        )
        
        // Store ALL properties including type
        var props = additionalProperties
        props["type"] = AnyCodable(elementType)
        self.additionalProperties = props
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        // Get type first
        guard let typeKey = container.allKeys.first(where: { $0.stringValue == "type" }),
              let typeString = try? container.decode(String.self, forKey: typeKey) else {
            throw DecodingError.dataCorruptedError(forKey: .init(stringValue: "type")!,
                                                  in: container,
                                                  debugDescription: "Type is required")
        }
        self.elementType = typeString
        
        // Store ALL properties including type
        var properties = [String: AnyCodable]()
        for key in container.allKeys {
            properties[key.stringValue] = try container.decode(AnyCodable.self, forKey: key)
        }
        
        try super.init(from: decoder)
        self.additionalProperties = properties
    }
    
    override func serializeToJsonValue() throws -> [String: Any] {
        return additionalProperties?.mapValues { $0.value } ?? [:]
    }
    
    static func createFromJSON(_ json: [String: Any]) throws -> SwiftUnknownElement {
        guard let typeString = json["type"] as? String else {
            throw AdaptiveCardParseError.invalidType
        }
        
        // Include all properties
        let properties = json.mapValues { AnyCodable($0) }
        
        return SwiftUnknownElement(elementType: typeString, additionalProperties: properties)
    }
}

// Maintain your existing parser
class SwiftUnknownElementParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftUnknownElement.createFromJSON(value)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let json = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: json)
    }
}
