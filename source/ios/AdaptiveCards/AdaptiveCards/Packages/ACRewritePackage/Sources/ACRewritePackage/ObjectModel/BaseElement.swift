import Foundation

/// Represents a base element in an adaptive card.
class BaseElement: Codable {
    var typeString: String
    var id: String?
    var internalId: InternalId
    var additionalProperties: [String: AnyCodable]?
    var requires: [String: SemanticVersion]?
    var fallbackType: FallbackType?
    var fallbackContent: BaseElement?
    var canFallbackToAncestor: Bool?
    
    // Add knownProperties for use in subclasses.
    var knownProperties: Set<String> = []

    init(
        typeString: String,
        id: String? = nil,
        internalId: InternalId = InternalId.current(),
        additionalProperties: [String: AnyCodable]? = nil,
        requires: [String: SemanticVersion]? = nil,
        fallbackType: FallbackType? = nil,
        fallbackContent: BaseElement? = nil,
        canFallbackToAncestor: Bool? = nil
    ) {
        self.typeString = typeString
        self.id = id
        self.internalId = internalId
        self.additionalProperties = additionalProperties
        self.requires = requires
        self.fallbackType = fallbackType
        self.fallbackContent = fallbackContent
        self.canFallbackToAncestor = canFallbackToAncestor
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode using the mapped key "type"
        self.typeString = try container.decode(String.self, forKey: .typeString)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.internalId = try container.decodeIfPresent(InternalId.self, forKey: .internalId) ?? InternalId.current()
        self.additionalProperties = try container.decodeIfPresent([String: AnyCodable].self, forKey: .additionalProperties)
        self.requires = try container.decodeIfPresent([String: SemanticVersion].self, forKey: .requires)
        self.fallbackType = try container.decodeIfPresent(FallbackType.self, forKey: .fallbackType)
        self.fallbackContent = try container.decodeIfPresent(BaseElement.self, forKey: .fallbackContent)
        self.canFallbackToAncestor = try container.decodeIfPresent(Bool.self, forKey: .canFallbackToAncestor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encode typeString using the key "type"
        try container.encode(typeString, forKey: .typeString)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(internalId, forKey: .internalId)
        try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)
        try container.encodeIfPresent(requires, forKey: .requires)
        try container.encodeIfPresent(fallbackType, forKey: .fallbackType)
        try container.encodeIfPresent(fallbackContent, forKey: .fallbackContent)
        try container.encodeIfPresent(canFallbackToAncestor, forKey: .canFallbackToAncestor)
    }
    
    private enum CodingKeys: String, CodingKey {
        case typeString = "type"  // Map the property typeString to the key "type"
        case id
        case internalId
        case additionalProperties
        case requires
        case fallbackType
        case fallbackContent
        case canFallbackToAncestor
    }
    
    /// Deserialize from JSON data.
    static func decode(from json: Data) throws -> BaseElement {
        return try JSONDecoder().decode(BaseElement.self, from: json)
    }
    
    /// Serialize to JSON data.
    func encodeToData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    /// Converts the element into a JSON dictionary.
    func toJSON() -> [String: Any] {
        var json: [String: Any] = ["type": typeString]
        if let id = id {
            json["id"] = id
        }
        if let additionalProperties = additionalProperties {
            for (key, anyCodable) in additionalProperties {
                json[key] = anyCodable.value
            }
        }
        // Additional properties (e.g. "requires", "fallbackType", etc.) can be added if desired.
        return json
    }
    /// Checks whether the element meets host requirements.
    func meetsRequirements(_ hostProvides: FeatureRegistration) -> Bool {
        guard let requires = requires else { return true }
        for (feature, requiredVersion) in requires {
            let hostVersionString = hostProvides.getFeatureVersion(featureName: feature)
            guard let hostVersion = try? SemanticVersion(hostVersionString) else {
                return false
            }
            
            if hostVersion < requiredVersion {
                return false
            }
        }
        return true
    }
}

/// Custom type to handle any JSON value (for additionalProperties)
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid JSON format")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [AnyCodable] {
            try container.encode(arrayValue)
        } else if let dictValue = value as? [String: AnyCodable] {
            try container.encode(dictValue)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid JSON format"))
        }
    }
}
