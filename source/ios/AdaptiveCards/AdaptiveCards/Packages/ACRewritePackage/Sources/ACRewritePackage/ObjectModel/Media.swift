import Foundation

/// Represents a media element containing sources and optional poster/alt text.
struct Media: Codable {
    var poster: String?
    var altText: String?
    var sources: [MediaSource]
    var captionSources: [CaptionSource]

    init(poster: String? = nil, altText: String? = nil, sources: [MediaSource] = [], captionSources: [CaptionSource] = []) {
        self.poster = poster
        self.altText = altText
        self.sources = sources
        self.captionSources = captionSources
    }

    /// Serialize `Media` to a JSON dictionary.
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

    /// Deserialize a `Media` object from JSON.
    static func deserialize(from json: [String: Any]) throws -> Media {
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(Media.self, from: jsonData)
    }

    /// Deserialize a `Media` object from a JSON string.
    static func deserialize(from jsonString: String) throws -> Media {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        return try JSONDecoder().decode(Media.self, from: jsonData)
    }

    /// Retrieves resource information (poster and media sources).
    func getResourceInformation() -> [RemoteResourceInformation] {
        var resourceInfo: [RemoteResourceInformation] = []

        if let poster = poster {
            resourceInfo.append(RemoteResourceInformation(url: poster, mimeType: "image"))
        }

        for source in sources {
            resourceInfo.append(contentsOf: source.getResourceInformation())
        }

        return resourceInfo
    }
}

/// Parses `Media` elements from JSON.
struct MediaParser {
    /// Parses a `Media` object from JSON data.
    static func deserialize(from json: [String: Any]) throws -> Media {
        guard let sourcesJson = json["sources"] as? [[String: Any]] else {
            throw NSError(domain: "Missing Media Sources", code: 0, userInfo: nil)
        }

        let sources = try sourcesJson.map { try MediaSource.deserialize(from: $0) }

        let captionSourcesJson = json["captionSources"] as? [[String: Any]] ?? []
        let captionSources = try captionSourcesJson.map { try CaptionSource.deserialize(from: $0) }

        let poster = json["poster"] as? String
        let altText = json["altText"] as? String

        return Media(poster: poster, altText: altText, sources: sources, captionSources: captionSources)
    }

    /// Parses a `Media` object from a JSON string.
    static func deserialize(from jsonString: String) throws -> Media {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON String", code: 0, userInfo: nil)
        }
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        guard let json = jsonObject else {
            throw NSError(domain: "Invalid JSON Format", code: 0, userInfo: nil)
        }
        return try deserialize(from: json)
    }
}

/// Represents a remote resource, such as a poster or media source.
struct RemoteResourceInformation: Codable {
    let url: String
    let mimeType: String
}
