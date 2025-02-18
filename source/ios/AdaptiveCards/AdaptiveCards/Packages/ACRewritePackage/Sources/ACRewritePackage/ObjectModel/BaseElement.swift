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
    // Singleton ParseContext instance
    private static var sharedParseContext: ParseContext = {
        let context = ParseContext()
        return context
    }()
    
    // Public getter for the shared context
    static var parseContext: ParseContext {
        return sharedParseContext
    }
    
    // Reset method for testing
    static func resetParseContext() {
        sharedParseContext = ParseContext()
    }

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
        // First decode all keys using a dynamic container.
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var rawDict = [String: AnyCodable]()
        for key in dynamicContainer.allKeys {
            rawDict[key.stringValue] = try dynamicContainer.decode(AnyCodable.self, forKey: key)
        }
        
        // Now decode known properties.
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.typeString = try container.decode(String.self, forKey: .typeString)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.internalId = try container.decodeIfPresent(InternalId.self, forKey: .internalId) ?? InternalId.current()
        self.requires = try container.decodeIfPresent([String: SemanticVersion].self, forKey: .requires)
        self.fallbackType = try container.decodeIfPresent(FallbackType.self, forKey: .fallbackType)
        self.fallbackContent = try container.decodeIfPresent(BaseElement.self, forKey: .fallbackContent)
        self.canFallbackToAncestor = try container.decodeIfPresent(Bool.self, forKey: .canFallbackToAncestor)
        // Also support the "fallback" key (which might be a string or an object)
        if container.contains(.fallback) {
            if let fallbackString = try? container.decode(String.self, forKey: .fallback) {
                if fallbackString.lowercased() == "drop" {
                    self.fallbackType = .drop
                }
            } else if let rawFallback = try? container.decode([String: AnyCodable].self, forKey: .fallback) {
                let fallbackDict = rawFallback.mapValues { $0.value }
                self.fallbackContent = try BaseCardElement.deserialize(from: fallbackDict)
            }
        }
        
        // Remove all keys that are declared in CodingKeys.
        for key in BaseElement.CodingKeys.allCases {
            rawDict.removeValue(forKey: key.rawValue)
        }
        if !rawDict.isEmpty {
            self.additionalProperties = rawDict
        }
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
    
    // MARK: - Overridable Serialization Method
    /// Serializes the BaseCardElement into a JSON dictionary.
    func serializeToJsonValue() throws -> [String: Any] {
        let json = self.toJSON()
        // Validate that the dictionary can be serialized.
        _ = try JSONSerialization.data(withJSONObject: json, options: [])
        return json
    }
    
    public enum CodingKeys: String, CodingKey {
        case typeString = "type"
        case id
        case internalId
        case additionalProperties
        case requires
        case fallbackType
        case fallbackContent
        case canFallbackToAncestor
        case fallback  // <-- New key for “fallback”
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
        // Add fallback info using the "fallback" key:
        if let fallbackContent = fallbackContent {
            json["fallback"] = fallbackContent.toJSON()
        } else if let fallbackType = fallbackType {
            json["fallback"] = fallbackType.rawValue
        }
        // Recursively unwrap AnyCodable values.
        if let unwrapped = ParseUtil.unwrapAnyCodable(from: json) as? [String: Any] {
            return unwrapped
        }
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

/// A dynamic coding key that can represent any key.
struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int? { return nil }
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.stringValue = "\(intValue)" }
}

extension BaseElement.CodingKeys: CaseIterable {
    static var allCases: [BaseElement.CodingKeys] {
        return [.typeString, .id, .internalId, .additionalProperties, .requires, .fallbackType, .fallbackContent, .canFallbackToAncestor, .fallback]
    }
}
