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

enum WarningStatusCode: String, Codable {
    case unknownElementType
    case unknownActionElementType
    case unknownPropertyOnElement
    case unknownEnumValue
    case noRendererForType
    case interactivityNotSupported
    case maxActionsExceeded
    case assetLoadFailed
    case unsupportedSchemaVersion
    case unsupportedMediaType
    case invalidMediaMix
    case invalidColorFormat
    case invalidDimensionSpecified
    case invalidLanguage
    case invalidValue
    case customWarning
    case emptyLabelInRequiredInput
    case requiredPropertyMissing
}
