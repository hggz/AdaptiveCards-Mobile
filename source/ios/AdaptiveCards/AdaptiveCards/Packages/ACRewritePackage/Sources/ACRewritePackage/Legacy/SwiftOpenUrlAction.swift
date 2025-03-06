import Foundation

/// Represents an OpenUrl action element in an adaptive card.
class SwiftOpenUrlAction: SwiftBaseActionElement {
    // MARK: - Properties
    let url: String

    // MARK: - Codable Implementation

    private enum CodingKeys: String, CodingKey {
        case url
    }

    /// Decodes OpenUrlAction-specific properties and then defers to the base class.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        try super.init(from: decoder)
    }

    /// Encodes OpenUrlAction-specific properties after encoding the base properties.
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
    }
}
