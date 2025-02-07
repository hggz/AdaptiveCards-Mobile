import Foundation

struct AdaptiveCardParseWarning: Codable {
    let statusCode: WarningStatusCode
    let message: String

    init(statusCode: WarningStatusCode, message: String) {
        self.statusCode = statusCode
        self.message = message
    }

    func getStatusCode() -> WarningStatusCode {
        return statusCode
    }

    func getReason() -> String {
        return message
    }
}
