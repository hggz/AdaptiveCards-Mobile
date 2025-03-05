import Foundation

/// Represents an unknown element in an Adaptive Card.
class SwiftUnknownElement: SwiftBaseCardElement {
    // MARK: - Properties
    private let elementType: String
    
    override var typeString: String {
        get { return elementType }
        set { /* Immutable property, setter required by protocol */ }
    }
    
    // MARK: - Codable Implementation
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        
        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        // Get type first
        guard let typeKey = container.allKeys.first(where: { $0.stringValue == "type" }),
              let typeString = try? container.decode(String.self, forKey: typeKey) else {
            throw DecodingError.dataCorruptedError(
                forKey: .init(stringValue: "type")!,
                in: container,
                debugDescription: "Type is required"
            )
        }
        
        // Set the element type before super.init
        elementType = typeString
        
        // Store ALL properties including type
        var properties = [String: AnyCodable]()
        for key in container.allKeys {
            properties[key.stringValue] = try container.decode(AnyCodable.self, forKey: key)
        }
        
        // Call super.init after initializing properties
        try super.init(from: decoder)
        self.additionalProperties = properties
    }
    
    // Custom initializer
    init(id: String? = nil, elementType: String, additionalProperties: [String: AnyCodable] = [:]) {
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
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        return additionalProperties?.mapValues { $0.value } ?? [:]
    }
}
