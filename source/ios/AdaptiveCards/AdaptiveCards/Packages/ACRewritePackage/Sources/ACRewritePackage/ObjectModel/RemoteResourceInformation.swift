import Foundation

/// Represents a remote resource with a URL and MIME type.
struct RemoteResourceInformation: Codable {
    var url: String
    var mimeType: String

    init(url: String, mimeType: String) {
        self.url = url
        self.mimeType = mimeType
    }
}
