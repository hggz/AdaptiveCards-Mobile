import Foundation

public struct SwiftAdaptiveCardParseWarning: Codable {
    let statusCode: SwiftWarningStatusCode
    let message: String

    init(statusCode: SwiftWarningStatusCode, message: String) {
        self.statusCode = statusCode
        self.message = message
    }

    func getStatusCode() -> SwiftWarningStatusCode {
        return statusCode
    }

    func getReason() -> String {
        return message
    }
}
