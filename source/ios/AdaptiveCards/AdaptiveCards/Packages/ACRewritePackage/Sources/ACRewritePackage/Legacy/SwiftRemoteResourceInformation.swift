import Foundation

/// Represents a remote resource with a URL and MIME type.
struct SwiftRemoteResourceInformation: Codable {
    var url: String
    var mimeType: String
}
