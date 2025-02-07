import Foundation

// Case-insensitive string equality comparator
struct CaseInsensitiveEqualTo {
    func isEqual<T: StringProtocol>(_ lhs: T, _ rhs: T) -> Bool {
        return lhs.caseInsensitiveCompare(rhs) == .orderedSame
    }
}

// Case-insensitive hash generator
struct CaseInsensitiveHash {
    func hash<T: StringProtocol>(_ keyval: T) -> Int {
        return keyval.lowercased().hashValue
    }
}

// Hash function for enums
struct EnumHash<T: Hashable> {
    func hash(_ value: T) -> Int {
        return value.hashValue
    }
}

// Enum mapping class for bidirectional enum <-> string conversion
struct EnumMapping<T: Hashable & Codable>: Codable {
    private let enumToString: [T: String]
    private let stringToEnum: [String: T]

    init(_ mappings: [(T, String)]) {
        var eToS = [T: String]()
        var sToE = [String: T]()

        for (enumValue, stringValue) in mappings {
            eToS[enumValue] = stringValue
            sToE[stringValue.lowercased()] = enumValue
        }

        self.enumToString = eToS
        self.stringToEnum = sToE
    }

    func toString(_ value: T) -> String {
        return enumToString[value] ?? "unknown"
    }

    func fromString(_ value: String) throws -> T {
        guard let enumValue = stringToEnum[value.lowercased()] else {
            throw EnumMappingError.invalidValue(value)
        }
        return enumValue
    }
}

// Error handling for invalid enum values
enum EnumMappingError: Error {
    case invalidValue(String)
}

// Enum mapping accessor functions
protocol AdaptiveCardEnum: Codable, Hashable {
    static var mappings: EnumMapping<Self> { get }
}

extension AdaptiveCardEnum {
    func toString() -> String {
        return Self.mappings.toString(self)
    }

    static func fromString(_ value: String) throws -> Self {
        return try Self.mappings.fromString(value)
    }
}

// Define `AdaptiveCardSchemaKey` using EnumMapping
enum AdaptiveCardSchemaKey: String, AdaptiveCardEnum {
    case accent, action, actionAlignment, actionMode, actionRole, actionSet, actionSetConfig
    case actions, actionsOrientation, adaptiveCard, allowCustomStyle, allowInlinePlayback
    case backgroundColor, backgroundImage, backgroundImageUrl, baseCardElement, baseContainerStyle
    case bleed, body, bolder, borderColor, bottom, badge, buttonSpacing, buttons, captionSources
    case card, cellSpacing, cells, center, choiceSet, choices, choicesData, choicesDataType, color
    case colorConfig, column, columnHeader, columnSet, columns, container, containerStyles, dark, data
    case dataQuery, dataset, dateInput, defaultCase, defaultPoster, description, elementId, emphasis
    case errorMessage, extraLarge, factSet, fallback, fallbackText, fontFamily, fontSizes, fontType
    case fontWeights, foregroundColor, foregroundColors, good, gridStyle, heading, headingLevel
    case height, highlight, highlightColor, highlightColors, horizontalAlignment, hostWidthBreakpoints
    case iconPlacement, iconSize, iconUrl, id, image, imageBaseUrl, imageSet, imageSize, imageSizes
    case images, inlineAction, inlineTopMargin, inlines, inputSpacing, inputs, isEnabled, isMultiSelect
    case isMultiline, showBorder, roundedCorners, isRequired, isSelected, isSubtle, isVisible, italic
    case items, label, language, large, left, light, lighter, lineColor, lineThickness, max, maxActions
    case maxImageHeight, maxLength, maxLines, maxWidth, media, medium, metaData, method, mimeType, min
    case minHeight, mode, monospace, narrow, numberInput, ratingInput, ratingLabel, padding, placeholder
    case playButton, poster, providerId, refresh, regex, repeatHorizontally, repeatVertically
    case requiredInputs, requires, richTextBlock, right, rows, rtl, schema, selectAction, separator
    case showActionMode, showCard, showCardActionConfig, showGridLines, size, small, sources, spacing
    case speak, standard, stretch, strikethrough, style, subtle, suffix, supportsInteractivity
    case table, tableCell, tableRow, targetElements, layout, itemFit, rowSpacing, columnSpacing
    case itemWidth, minItemWidth, maxItemWidth, horizontalItemsAlignment, row, rowSpan, columnSpan
    case areaGridName, areas, layouts, targetInputIds, targetWidth, text, textBlock, textConfig
    case textInput, textStyles, marigoldColor, neutralColor, filledStar, emptyStar, ratingTextColor
    case countTextColor, textWeight, thickness, timeInput, title, toggleInput, tooltip, top, type
    case underline, uri, url, userIds, value, valueChangedAction, valueChangedActionType, valueOff
    case valueOn, verb, veryNarrow, version, verticalAlignment, verticalCellContentAlignment
    case verticalContentAlignment, warning, webUrl, weight, width, wrap, compoundButton, authentication

    static let mappings = EnumMapping([
        (.accent, "accent"),
        (.action, "action"),
        (.actionAlignment, "actionAlignment"),
        (.actionMode, "actionMode"),
        (.actionRole, "role"),
        (.actionSet, "ActionSet"),
        (.actionSetConfig, "actionSetConfig"),
        (.actions, "actions"),
        (.actionsOrientation, "actionsOrientation"),
        (.adaptiveCard, "adaptiveCard"),
        (.allowCustomStyle, "allowCustomStyle"),
        (.allowInlinePlayback, "allowInlinePlayback"),
        (.backgroundColor, "backgroundColor"),
        (.backgroundImage, "backgroundImage"),
        (.backgroundImageUrl, "backgroundImageUrl"),
        (.baseCardElement, "baseCardElement"),
        (.baseContainerStyle, "baseContainerStyle"),
        (.badge, "badge"),
        (.bleed, "bleed"),
        (.body, "body"),
        (.bolder, "bolder"),
        (.borderColor, "borderColor"),
        (.bottom, "bottom"),
        (.buttonSpacing, "buttonSpacing"),
        (.buttons, "buttons"),
        (.captionSources, "captionSources"),
        (.card, "card"),
        (.cellSpacing, "cellSpacing"),
        (.cells, "cells"),
        (.center, "center"),
        (.choiceSet, "choiceSet"),
        (.choices, "choices"),
        (.choicesData, "choices.data"),
        (.choicesDataType, "type"),
        (.color, "color"),
        (.colorConfig, "colorConfig"),
        (.column, "column"),
        (.columnHeader, "columnHeader"),
        (.columnSet, "columnSet"),
        (.columns, "columns"),
        (.container, "container"),
        (.containerStyles, "containerStyles"),
        (.dark, "dark"),
        (.data, "data"),
        (.dataQuery, "Data.Query"),
        (.dataset, "dataset"),
        (.dateInput, "dateInput"),
        (.defaultCase, "default"),
        (.defaultPoster, "defaultPoster"),
        (.description, "description"),
        (.elementId, "elementId"),
        (.emphasis, "emphasis"),
        (.errorMessage, "errorMessage"),
        (.extraLarge, "extraLarge"),
        (.factSet, "factSet"),
        (.facts, "facts"),
        (.fallback, "fallback"),
        (.fallbackText, "fallbackText"),
        (.fontFamily, "fontFamily"),
        (.fontSizes, "fontSizes"),
        (.fontType, "fontType"),
        (.fontWeights, "fontWeights"),
        (.foregroundColor, "foregroundColor"),
        (.foregroundColors, "foregroundColors"),
        (.good, "good"),
        (.gridStyle, "gridStyle"),
        (.heading, "heading"),
        (.headingLevel, "headingLevel"),
        (.height, "height"),
        (.highlight, "highlight"),
        (.highlightColor, "highlightColor"),
        (.highlightColors, "highlightColors"),
        (.horizontalAlignment, "horizontalAlignment"),
        (.hostWidthBreakpoints, "hostWidthBreakpoints")
    ])
}
