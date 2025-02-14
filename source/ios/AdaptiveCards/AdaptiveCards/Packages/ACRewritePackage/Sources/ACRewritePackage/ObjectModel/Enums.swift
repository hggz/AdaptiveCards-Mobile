import Foundation

enum CardElementType: String, Codable {
    case actionSet, adaptiveCard, choiceInput, choiceSetInput, column, columnSet, container, custom, dateInput, fact, factSet
    case image, icon, imageSet, media, numberInput, ratingInput, ratingLabel, richTextBlock, table, tableCell, tableRow, textBlock
    case textInput, timeInput, toggleInput, compoundButton, unknown
}

/// Enum representing possible text sizes.
enum TextSize: String, Codable {
    case defaultSize = "Default"
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case extraLarge = "ExtraLarge"

    init(from rawValue: String) {
        self = TextSize(rawValue: rawValue) ?? .defaultSize
    }
}

/// Enum representing possible text weights.
enum TextWeight: String, Codable {
    case defaultWeight = "Default"
    case lighter = "Lighter"
    case bolder = "Bolder"

    init(from rawValue: String) {
        self = TextWeight(rawValue: rawValue) ?? .defaultWeight
    }
}

/// Enum representing possible font types.
enum FontType: String, Codable {
    case defaultFont = "Default"
    case monospace = "Monospace"

    init(from rawValue: String) {
        self = FontType(rawValue: rawValue) ?? .defaultFont
    }
}

enum ForegroundColor: String, Codable {
    case `default`, dark, light, accent, good, warning, attention
}

/// Enum representing possible horizontal alignments.
enum HorizontalAlignment: String, Codable {
    case left = "Left"
    case center = "Center"
    case right = "Right"

    init(from rawValue: String) {
        self = HorizontalAlignment(rawValue: rawValue) ?? .left
    }
    
    static func fromString(_ value: String) -> HorizontalAlignment? {
        return HorizontalAlignment(rawValue: value)
    }
}

enum VerticalAlignment: String, Codable {
    case top, center, bottom
}

enum ImageSize: String, Codable {
    case none, auto, stretch, small, medium, large
}

enum TextInputStyle: String, Codable {
    case text, tel, url, email, password
    static func fromString(_ value: String) -> TextInputStyle? {
        return TextInputStyle(rawValue: value)
    }
}

enum ActionType: String, Codable {
    case unsupported, execute, openUrl, showCard, submit, toggleVisibility, custom, unknownAction, overflow
}

enum ActionAlignment: String, Codable {
    case left, center, right, stretch
}

enum ChoiceSetStyle: String, Codable {
    case compact = "Compact"
    case expanded = "Expanded"
    case filtered = "Filtered"
}

enum Spacing: String, Codable {
    case `default`, none, small, medium, large, extraLarge, padding
}

enum ActionsOrientation: String, Codable {
    case vertical, horizontal
}

enum ContainerStyle: String, Codable {
    case none, `default`, emphasis, good, attention, warning, accent
    static func fromString(_ value: String) -> ContainerStyle? {
        return ContainerStyle(rawValue: value)
    }
}

enum Mode: String, Codable {
    case primary, secondary
}

enum ErrorStatusCode: String, Codable {
    case invalidJson, renderFailed, requiredPropertyMissing, invalidPropertyValue, unsupportedParserOverride, idCollision, customError
}

enum WarningStatusCode: String, Codable {
    case unknownElementType, unknownActionElementType, unknownPropertyOnElement, unknownEnumValue, noRendererForType
    case interactivityNotSupported, maxActionsExceeded, assetLoadFailed, unsupportedSchemaVersion, unsupportedMediaType
    case invalidMediaMix, invalidColorFormat, invalidDimensionSpecified, invalidLanguage, invalidValue, customWarning
    case emptyLabelInRequiredInput, requiredPropertyMissing
}

enum HostWidth: String, Codable {
    case `default`, veryNarrow, narrow, standard, wide
    static func < (lhs: HostWidth, rhs: HostWidth) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    static func <= (lhs: HostWidth, rhs: HostWidth) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
    static func >= (lhs: HostWidth, rhs: HostWidth) -> Bool {
        return lhs.rawValue >= rhs.rawValue
    }
}

enum TargetWidthType: String, Codable {
    case `default`, veryNarrow, narrow, standard, wide
    case atMostVeryNarrow, atMostNarrow, atMostStandard, atMostWide
    case atLeastVeryNarrow, atLeastNarrow, atLeastStandard, atLeastWide
}
