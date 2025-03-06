import Foundation

/// Represents a media source, inheriting properties from `ContentSource`.
struct SwiftMediaSource: Codable {
    // MARK: - Properties
    let url: String
    let mimeType: String?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case url, mimeType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        url = try container.decode(String.self, forKey: .url)
        mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
    }
    
    // MARK: - Initialization with Default Values
    
    // MARK: - Serialization to JSON
    func serializeToJson() -> [String: Any] {
        return SwiftMediaSourceLegacySupport.serializeToJson(self)
    }
    
    // MARK: - Resource Information
    func getResourceInformation() -> [SwiftRemoteResourceInformation] {
        return SwiftMediaSourceLegacySupport.getResourceInformation(self)
    }
}
