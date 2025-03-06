import Foundation

final class SwiftUnknownAction: SwiftBaseActionElement {
    // Store the original type string from JSON.
    private var originalTypeString: String

    override var typeString: String {
        get {
            // Special handling: if the original type is "Action.Invalid",
            // return the standardized unknown action type.
            if originalTypeString == "Action.Invalid" {
                return SwiftActionType.unknownAction.rawValue
            }
            return originalTypeString
        }
        set { originalTypeString = newValue }
    }
    
    /// Designated initializer.
    init(type: String) {
        self.originalTypeString = type
        super.init(type: .unknownAction)
    }
    
    /// Custom decoder that captures all JSON properties.
    required init(from decoder: Decoder) throws {
        // Use dynamic coding keys to iterate over all keys.
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        // Retrieve the original type from the JSON.
        guard let typeKey = container.allKeys.first(where: { $0.stringValue == "type" }),
              let typeString = try? container.decode(String.self, forKey: typeKey) else {
            throw DecodingError.dataCorruptedError(
                forKey: DynamicCodingKeys(stringValue: "type")!,
                in: container,
                debugDescription: "Type is required"
            )
        }
        self.originalTypeString = typeString
        
        // Decode all properties into a dictionary.
        var properties = [String: AnyCodable]()
        for key in container.allKeys {
            properties[key.stringValue] = try container.decode(AnyCodable.self, forKey: key)
        }
        
        super.init(type: .unknownAction)
        self.additionalProperties = properties
    }
    
    /// Encode additional properties using dynamic keys.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        if let additionalProperties = additionalProperties {
            for (key, value) in additionalProperties {
                try container.encode(value, forKey: DynamicCodingKeys(stringValue: key)!)
            }
        }
    }
    
    /// Legacy serialization: returns all captured properties.
    override func serializeToJsonValue() throws -> [String: Any] {
        return additionalProperties?.mapValues { $0.value } ?? [:]
    }
}
