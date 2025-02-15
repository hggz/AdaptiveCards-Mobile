import Foundation

/// Represents a media element containing sources and optional poster/alt text.
class Media: BaseCardElement {
    var poster: String?
    var altText: String?
    var sources: [MediaSource]
    var captionSources: [CaptionSource]
    
    /// Designated initializer.
    init(id: String? = nil,
         poster: String? = nil,
         altText: String? = nil,
         sources: [MediaSource] = [],
         captionSources: [CaptionSource] = []) {
        self.poster = poster
        self.altText = altText
        self.sources = sources
        self.captionSources = captionSources
        super.init(
            type: .media,
            spacing: nil,
            height: nil,
            targetWidth: nil,
            separator: nil,
            isVisible: true,
            areaGridName: nil,
            id: id
        )
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case poster, altText, sources, captionSources
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.poster = try container.decodeIfPresent(String.self, forKey: .poster)
        self.altText = try container.decodeIfPresent(String.self, forKey: .altText)
        self.sources = try container.decode([MediaSource].self, forKey: .sources)
        self.captionSources = try container.decode([CaptionSource].self, forKey: .captionSources)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(poster, forKey: .poster)
        try container.encodeIfPresent(altText, forKey: .altText)
        try container.encode(sources, forKey: .sources)
        try container.encode(captionSources, forKey: .captionSources)
        try super.encode(to: encoder)
    }
    
    // MARK: - JSON Serialization
    /// Converts the Media object into a JSON dictionary.
    func serializeToJson() -> [String: Any] {
        var json: [String: Any] = [:]
        if let poster = poster {
            json["poster"] = poster
        }
        if let altText = altText {
            json["altText"] = altText
        }
        json["sources"] = sources.map { $0.serializeToJson() }
        json["captionSources"] = captionSources.map { $0.serializeToJson() }
        return json
    }
    
    /// Returns a JSON string representation.
    func toJSONString() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: serializeToJson(), options: .prettyPrinted)
            return String(data: data, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
    
    // MARK: - Resource Information
    /// Retrieves resource information (from poster and media sources).
    /// Renamed from `getResourceInformation()` to avoid conflicting with BaseCardElement’s extension.
    func mediaResourceInformation() -> [RemoteResourceInformation] {
        var resourceInfo: [RemoteResourceInformation] = []
        if let poster = poster {
            resourceInfo.append(RemoteResourceInformation(url: poster, mimeType: "image"))
        }
        for source in sources {
            resourceInfo.append(contentsOf: source.getResourceInformation())
        }
        return resourceInfo
    }
    
    // MARK: - Utility Deserialization
    /// Creates a Media object from a JSON dictionary.
    static func createFromJSON(_ json: [String: Any]) throws -> Media {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(Media.self, from: data)
    }
    
    /// Creates a Media object from a JSON string.
    static func createFromJSONString(_ jsonString: String) throws -> Media {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(Media.self, from: data)
    }
}

/// Parses Media elements in an Adaptive Card.
class MediaParser: BaseCardElementParser {
    func deserialize(context: inout ParseContext, value: [String: Any]) throws -> BaseCardElement {
        return try Media.createFromJSON(value)
    }
    
    func deserialize(fromString context: inout ParseContext, value: String) throws -> BaseCardElement {
        return try Media.createFromJSONString(value)
    }
}
