import Foundation

/// Represents a token exchange resource in Adaptive Cards.
struct TokenExchangeResource: Codable {
    /// The unique identifier for the token exchange resource.
    var id: String?
    
    /// The URI associated with the resource.
    var uri: String?
    
    /// The provider ID for the resource.
    var providerId: String?

    /// Initializes a new `TokenExchangeResource`.
    init(id: String? = nil, uri: String? = nil, providerId: String? = nil) {
        self.id = id
        self.uri = uri
        self.providerId = providerId
    }

    /// Determines if serialization should occur based on whether fields have been set.
    var shouldSerialize: Bool {
        return id != nil || uri != nil || providerId != nil
    }

    /// Serializes the resource to a JSON string.
    func serialize() throws -> String {
        let jsonData = try JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8) ?? ""
    }

    /// Serializes the resource into a JSON object.
    func serializeToJsonValue() throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:]
    }

    /// Deserializes a `TokenExchangeResource` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> TokenExchangeResource {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(TokenExchangeResource.self, from: jsonData)
    }

    /// Deserializes a `TokenExchangeResource` from a JSON string.
    static func deserialize(from jsonString: String) throws -> TokenExchangeResource {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AdaptiveCardError.invalidJson
        }
        return try JSONDecoder().decode(TokenExchangeResource.self, from: jsonData)
    }

    /// Coding keys for JSON serialization.
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case uri = "uri"
        case providerId = "providerId"
    }
}
