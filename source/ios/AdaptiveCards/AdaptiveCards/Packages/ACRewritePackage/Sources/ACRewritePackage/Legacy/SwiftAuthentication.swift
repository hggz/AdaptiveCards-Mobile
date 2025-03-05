import Foundation

struct SwiftAuthentication: Codable {
    let text: String
    let connectionName: String
    let tokenExchangeResource: SwiftTokenExchangeResource?
    let buttons: [SwiftAuthCardButton]
}
