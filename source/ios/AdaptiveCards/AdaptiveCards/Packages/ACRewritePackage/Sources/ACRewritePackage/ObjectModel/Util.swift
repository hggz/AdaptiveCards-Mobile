import Foundation

/// Validates a given hex color string and ensures it is in the correct format.
func validateColor(_ backgroundColor: String, warnings: inout [AdaptiveCardParseWarning]) -> String {
    guard !backgroundColor.isEmpty else { return backgroundColor }
    
    let backgroundColorLength = backgroundColor.count
    let isValidColor = backgroundColor.first == "#" && (backgroundColorLength == 7 || backgroundColorLength == 9) &&
                       backgroundColor.dropFirst().allSatisfy { $0.isHexDigit }
    
    if !isValidColor {
        warnings.append(AdaptiveCardParseWarning(
            statusCode: .invalidColorFormat,
            message: "Image background color specified, but doesn't follow #AARRGGBB or #RRGGBB format"
        ))
        return "#00000000"
    }
    
    return backgroundColorLength == 7 ? "#FF\(backgroundColor.dropFirst())" : backgroundColor
}

/// Parses a string representing a size in pixels and returns an optional integer.
func parseSizeForPixelSize(_ sizeString: String, warnings: inout [AdaptiveCardParseWarning]?) -> Int? {
    guard shouldParseForExplicitDimension(sizeString) else { return nil }
    return validateUserInputForDimensionWithUnit("px", sizeString, warnings: &warnings)
}

/// Ensures that all ShowCard actions have the correct version assigned.
func ensureShowCardVersions(_ actions: [BaseActionElement], version: String) {
    for action in actions {
        if let showCardAction = action as? ShowCardAction, showCardAction.card?.version.isEmpty == true {
            showCardAction.card?.version = version
        }
    }
}

/// Handles unknown properties by extracting properties that are not in the known properties set.
func handleUnknownProperties(from json: [String: Any], knownProperties: Set<String>) -> [String: Any] {
    var unknownProperties: [String: Any] = [:]
    for (key, value) in json where !knownProperties.contains(key) {
        unknownProperties[key] = value
    }
    return unknownProperties
}

/// Validates user input for a dimension with a specified unit.
private func validateUserInputForDimensionWithUnit(_ unit: String, _ requestedDimension: String, warnings: inout [AdaptiveCardParseWarning]?) -> Int? {
    let regexPattern = #"^([1-9]\d*)(\.\d+)?(\#(unit))$"#
    let warningMessage = "Expected input argument to be specified as \\d+(\\.\\d+)?px with no spaces, but received \(requestedDimension)"
    
    guard let match = requestedDimension.range(of: regexPattern, options: .regularExpression) else {
        warnings?.append(AdaptiveCardParseWarning(statusCode: .invalidDimensionSpecified, message: warningMessage))
        return nil
    }
    
    let numberString = String(requestedDimension[match])
    return Int(numberString) ?? {
        warnings?.append(AdaptiveCardParseWarning(statusCode: .invalidDimensionSpecified, message: "Invalid number format: \(requestedDimension)"))
        return nil
    }()
}

/// Determines whether an input string should be parsed for an explicit dimension.
private func shouldParseForExplicitDimension(_ input: String) -> Bool {
    guard !input.isEmpty else { return false }
    return input.first == "-" || input.first == "." || input.contains(where: { $0.isNumber }) && input.contains(where: { $0.isLetter || $0 == "." })
}
