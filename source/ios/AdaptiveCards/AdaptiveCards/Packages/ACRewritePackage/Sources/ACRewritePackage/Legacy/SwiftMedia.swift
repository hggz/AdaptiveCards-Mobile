import Foundation

/// Represents a media element containing sources and optional poster/alt text.
class SwiftMedia: SwiftBaseCardElement {
    // MARK: - Properties
    let poster: String?
    let altText: String?
    let sources: [SwiftMediaSource]
    let captionSources: [SwiftCaptionSource]
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case poster, altText, sources, captionSources
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        poster = try container.decodeIfPresent(String.self, forKey: .poster)
        altText = try container.decodeIfPresent(String.self, forKey: .altText)
        sources = try container.decode([SwiftMediaSource].self, forKey: .sources)
        captionSources = try container.decodeIfPresent([SwiftCaptionSource].self, forKey: .captionSources) ?? []
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(poster, forKey: .poster)
        try container.encodeIfPresent(altText, forKey: .altText)
        try container.encode(sources, forKey: .sources)
        try container.encode(captionSources, forKey: .captionSources)
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
