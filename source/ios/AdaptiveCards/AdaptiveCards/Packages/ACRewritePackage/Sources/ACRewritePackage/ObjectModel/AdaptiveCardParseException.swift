import Foundation

/// Represents an error encountered while parsing an Adaptive Card.
struct AdaptiveCardParseException: Error {
    let statusCode: ErrorStatusCode
    let message: String
    
    init(statusCode: ErrorStatusCode, message: String) {
        self.statusCode = statusCode
        self.message = message
    }
}

extension AdaptiveCardParseException: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
