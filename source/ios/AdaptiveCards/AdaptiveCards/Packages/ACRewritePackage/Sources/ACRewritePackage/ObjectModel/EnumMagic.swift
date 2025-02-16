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

// Protocol to allow enums to use the mapping
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
    case errorMessage, extraLarge, factSet, facts, fallback, fallbackText, fontFamily, fontSizes, fontType
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
    case associatedInputs
    case conditionallyEnabled

    static let mappings = EnumMapping([
        (AdaptiveCardSchemaKey.accent, "accent"),
        (AdaptiveCardSchemaKey.action, "action"),
        (AdaptiveCardSchemaKey.actionAlignment, "actionAlignment"),
        (AdaptiveCardSchemaKey.actionMode, "actionMode"),
        (AdaptiveCardSchemaKey.actionRole, "role"),
        (AdaptiveCardSchemaKey.actionSet, "ActionSet"),
        (AdaptiveCardSchemaKey.actionSetConfig, "actionSetConfig"),
        (AdaptiveCardSchemaKey.actions, "actions"),
        (AdaptiveCardSchemaKey.actionsOrientation, "actionsOrientation"),
        (AdaptiveCardSchemaKey.adaptiveCard, "adaptiveCard"),
        (AdaptiveCardSchemaKey.allowCustomStyle, "allowCustomStyle"),
        (AdaptiveCardSchemaKey.allowInlinePlayback, "allowInlinePlayback"),
        (AdaptiveCardSchemaKey.backgroundColor, "backgroundColor"),
        (AdaptiveCardSchemaKey.backgroundImage, "backgroundImage"),
        (AdaptiveCardSchemaKey.backgroundImageUrl, "backgroundImageUrl"),
        (AdaptiveCardSchemaKey.baseCardElement, "baseCardElement"),
        (AdaptiveCardSchemaKey.baseContainerStyle, "baseContainerStyle"),
        (AdaptiveCardSchemaKey.badge, "badge"),
        (AdaptiveCardSchemaKey.bleed, "bleed"),
        (AdaptiveCardSchemaKey.body, "body"),
        (AdaptiveCardSchemaKey.bolder, "bolder"),
        (AdaptiveCardSchemaKey.borderColor, "borderColor"),
        (AdaptiveCardSchemaKey.bottom, "bottom"),
        (AdaptiveCardSchemaKey.buttonSpacing, "buttonSpacing"),
        (AdaptiveCardSchemaKey.buttons, "buttons"),
        (AdaptiveCardSchemaKey.captionSources, "captionSources"),
        (AdaptiveCardSchemaKey.card, "card"),
        (AdaptiveCardSchemaKey.cellSpacing, "cellSpacing"),
        (AdaptiveCardSchemaKey.cells, "cells"),
        (AdaptiveCardSchemaKey.center, "center"),
        (AdaptiveCardSchemaKey.choiceSet, "choiceSet"),
        (AdaptiveCardSchemaKey.choices, "choices"),
        (AdaptiveCardSchemaKey.choicesData, "choices.data"),
        (AdaptiveCardSchemaKey.choicesDataType, "type"),
        (AdaptiveCardSchemaKey.color, "color"),
        (AdaptiveCardSchemaKey.colorConfig, "colorConfig"),
        (AdaptiveCardSchemaKey.column, "column"),
        (AdaptiveCardSchemaKey.columnHeader, "columnHeader"),
        (AdaptiveCardSchemaKey.columnSet, "columnSet"),
        (AdaptiveCardSchemaKey.columns, "columns"),
        (AdaptiveCardSchemaKey.container, "container"),
        (AdaptiveCardSchemaKey.containerStyles, "containerStyles"),
        (AdaptiveCardSchemaKey.dark, "dark"),
        (AdaptiveCardSchemaKey.data, "data"),
        (AdaptiveCardSchemaKey.dataQuery, "Data.Query"),
        (AdaptiveCardSchemaKey.dataset, "dataset"),
        (AdaptiveCardSchemaKey.dateInput, "dateInput"),
        (AdaptiveCardSchemaKey.defaultCase, "default"),
        (AdaptiveCardSchemaKey.defaultPoster, "defaultPoster"),
        (AdaptiveCardSchemaKey.description, "description"),
        (AdaptiveCardSchemaKey.elementId, "elementId"),
        (AdaptiveCardSchemaKey.emphasis, "emphasis"),
        (AdaptiveCardSchemaKey.errorMessage, "errorMessage"),
        (AdaptiveCardSchemaKey.extraLarge, "extraLarge"),
        (AdaptiveCardSchemaKey.factSet, "factSet"),
        (AdaptiveCardSchemaKey.facts, "facts"),
        (AdaptiveCardSchemaKey.fallback, "fallback"),
        (AdaptiveCardSchemaKey.fallbackText, "fallbackText"),
        (AdaptiveCardSchemaKey.fontFamily, "fontFamily"),
        (AdaptiveCardSchemaKey.fontSizes, "fontSizes"),
        (AdaptiveCardSchemaKey.fontType, "fontType"),
        (AdaptiveCardSchemaKey.fontWeights, "fontWeights"),
        (AdaptiveCardSchemaKey.foregroundColor, "foregroundColor"),
        (AdaptiveCardSchemaKey.foregroundColors, "foregroundColors"),
        (AdaptiveCardSchemaKey.good, "good"),
        (AdaptiveCardSchemaKey.gridStyle, "gridStyle"),
        (AdaptiveCardSchemaKey.heading, "heading"),
        (AdaptiveCardSchemaKey.headingLevel, "headingLevel"),
        (AdaptiveCardSchemaKey.height, "height"),
        (AdaptiveCardSchemaKey.highlight, "highlight"),
        (AdaptiveCardSchemaKey.highlightColor, "highlightColor"),
        (AdaptiveCardSchemaKey.highlightColors, "highlightColors"),
        (AdaptiveCardSchemaKey.horizontalAlignment, "horizontalAlignment"),
        (AdaptiveCardSchemaKey.hostWidthBreakpoints, "hostWidthBreakpoints"),
        (AdaptiveCardSchemaKey.associatedInputs, "associatedInputs"),
        (AdaptiveCardSchemaKey.conditionallyEnabled, "conditionallyEnabled"),
    ])
}

extension AdaptiveCardSchemaKey {
    static func fromString(_ s: String) -> AdaptiveCardSchemaKey? {
        return try? mappings.fromString(s)
    }

    static func toString(_ value: AdaptiveCardSchemaKey) -> String {
        return mappings.toString(value)
    }
}
