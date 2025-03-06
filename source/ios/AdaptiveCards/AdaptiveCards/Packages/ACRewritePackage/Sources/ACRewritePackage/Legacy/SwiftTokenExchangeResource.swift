import Foundation

/// Represents a token exchange resource in Adaptive Cards.
struct SwiftTokenExchangeResource: Codable {
    /// The unique identifier for the token exchange resource.
    let id: String?
    
    /// The URI associated with the resource.
    let uri: String?
    
    /// The provider ID for the resource.
    let providerId: String?
}
