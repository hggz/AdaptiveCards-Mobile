import Foundation

public struct SwiftAdaptiveCardParseWarning: Codable {
    let statusCode: SwiftWarningStatusCode
    let message: String

    init(statusCode: SwiftWarningStatusCode, message: String) {
        self.statusCode = statusCode
        self.message = message
    }

    public func getStatusCode() -> SwiftWarningStatusCode {
        return statusCode
    }

    public func getReason() -> String {
        return message
    }
}
