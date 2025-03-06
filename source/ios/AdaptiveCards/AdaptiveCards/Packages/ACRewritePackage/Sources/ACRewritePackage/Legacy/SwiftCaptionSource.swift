import Foundation

/// Represents a caption source in an Adaptive Card.
struct SwiftCaptionSource: Codable {
    // MARK: - Properties
    let mimeType: String?
    let url: String?
    let label: String?
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case mimeType = "MimeType"
        case url = "Url"
        case label = "Label"
    }
}
