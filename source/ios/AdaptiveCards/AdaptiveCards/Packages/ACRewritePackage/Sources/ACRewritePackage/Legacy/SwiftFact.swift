import Foundation

struct SwiftFact: Codable {
    // MARK: - Properties
    var title: String
    var value: String
    let language: String?

    // MARK: - Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case title
        case value
        case language
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
        language = try container.decodeIfPresent(String.self, forKey: .language)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
        try container.encodeIfPresent(language, forKey: .language)
    }
    
    // MARK: - Serialization to JSON
    func serializeToJsonValue() -> [String: Any] {
        return SwiftFactLegacySupport.serializeToJson(self)
    }
}
