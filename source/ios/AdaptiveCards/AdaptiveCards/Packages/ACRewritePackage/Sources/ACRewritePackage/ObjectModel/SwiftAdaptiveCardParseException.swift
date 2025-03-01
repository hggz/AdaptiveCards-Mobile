import Foundation

/// Represents an error encountered while parsing an Adaptive Card.
struct SwiftAdaptiveCardParseException: Error {
    let statusCode: SwiftErrorStatusCode
    let message: String
    
    init(statusCode: SwiftErrorStatusCode, message: String) {
        self.statusCode = statusCode
        self.message = message
    }
    
    // Added to satisfy tests:
    func what() -> String {
        return message
    }
    
    func getStatusCode() -> SwiftErrorStatusCode {
        return statusCode
    }
    
    func getReason() -> String {
        return message
    }
}

extension SwiftAdaptiveCardParseException: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
