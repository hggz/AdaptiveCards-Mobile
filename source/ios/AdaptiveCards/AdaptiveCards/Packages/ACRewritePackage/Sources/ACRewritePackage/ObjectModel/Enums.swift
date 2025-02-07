import Foundation

enum AdaptiveCardSchemaKey: String, Codable {
    case accent, action, actionAlignment, actionMode, actionOrientation, actionRole, actionSet, actionSetConfig, actions, actionsOrientation, adaptiveCard
    case allowCustomStyle, allowInlinePlayback, altText, name, associatedInputs, attention, authentication, backgroundColor, backgroundImage
    case backgroundImageUrl, baseCardElement, baseContainerStyle, bleed, body, bolder, borderColor, bottom, badge, buttonSpacing, buttons
    case captionSources, card, cellSpacing, cells, center, choiceSet, choices, choicesData, choicesDataType, color, colorConfig, column
    case columnHeader, columnSet, columns, conditionallyEnabled, connectionName, container, containerStyles, borderWidth, cornerRadius
    case dark, data, dataQuery, dataset, dateInput, defaultCase, defaultPoster, count, description, elementId, emphasis, errorMessage
    case extraLarge, factSet, facts, fallback, fallbackText, fillMode, firstRowAsHeaders, fontFamily, fontSizes, fontType, fontTypes
    case fontWeights, foregroundColor, foregroundColors, good, gridStyle, heading, headingLevel, height, highlight, highlightColor
    case highlightColors, horizontalAlignment, horizontalCellContentAlignment, hostWidthBreakpoints, iconPlacement, iconSize, iconUrl, id
    case image, icon, imageBaseUrl, imageSet, imageSize, imageSizes, images, inlineAction, inlineTopMargin, inlines, inputSpacing, inputs
    case isEnabled, isMultiSelect, isMultiline, showBorder, roundedCorners, isRequired, isSelected, isSubtle, isVisible, italic, items, label
    case language, large, left, light, lighter, lineColor, lineThickness, max, maxActions, maxImageHeight, maxLength, maxLines, maxWidth
    case media, medium, metaData, method, mimeType, min, minHeight, mode, monospace, narrow, numberInput, ratingInput, ratingLabel
    case optionalInputs, padding, placeholder, playButton, poster, providerId, refresh, regex, repeatCase, repeatHorizontally, repeatVertically
    case requiredInputs, requires, richTextBlock, right, rows, rtl, schema, selectAction, separator, showActionMode, showCard
    case showCardActionConfig, showGridLines, size, small, sources, spacing, spacingDefinition, speak, standard, stretch, strikethrough
    case style, subtle, suffix, supportsInteractivity, table, tableCell, tableRow, targetElements, layout, itemFit, rowSpacing
    case columnSpacing, itemWidth, minItemWidth, maxItemWidth, horizontalItemsAlignment, row, rowSpan, columnSpan, areaGridName
    case areas, layouts, targetInputIds, targetWidth, text, textBlock, textConfig, textInput, textStyles, marigoldColor, neutralColor
    case filledStar, emptyStar, ratingTextColor, countTextColor, textWeight, thickness, timeInput, title, toggleInput, tokenExchangeResource
    case tooltip, top, type, underline, uri, url, userIds, value, valueChangedAction, valueChangedActionType, valueOff, valueOn
    case verb, veryNarrow, version, verticalAlignment, verticalCellContentAlignment, verticalContentAlignment, warning, webUrl
    case weight, width, wrap, compoundButton
}

enum CardElementType: String, Codable {
    case actionSet, adaptiveCard, choiceInput, choiceSetInput, column, columnSet, container, custom, dateInput, fact, factSet
    case image, icon, imageSet, media, numberInput, ratingInput, ratingLabel, richTextBlock, table, tableCell, tableRow, textBlock
    case textInput, timeInput, toggleInput, compoundButton, unknown
}

enum TextSize: String, Codable {
    case small, `default`, medium, large, extraLarge
}

enum TextWeight: String, Codable {
    case lighter, `default`, bolder
}

enum FontType: String, Codable {
    case `default`, monospace
}

enum ForegroundColor: String, Codable {
    case `default`, dark, light, accent, good, warning, attention
}

enum HorizontalAlignment: String, Codable {
    case left, center, right
}

enum VerticalAlignment: String, Codable {
    case top, center, bottom
}

enum ImageSize: String, Codable {
    case none, auto, stretch, small, medium, large
}

enum TextInputStyle: String, Codable {
    case text, tel, url, email, password
}

enum ActionType: String, Codable {
    case unsupported, execute, openUrl, showCard, submit, toggleVisibility, custom, unknownAction, overflow
}

enum ActionAlignment: String, Codable {
    case left, center, right, stretch
}

enum ChoiceSetStyle: String, Codable {
    case compact, expanded, filtered
}

enum Spacing: String, Codable {
    case `default`, none, small, medium, large, extraLarge, padding
}

enum ActionsOrientation: String, Codable {
    case vertical, horizontal
}

enum ContainerStyle: String, Codable {
    case none, `default`, emphasis, good, attention, warning, accent
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
}

enum TargetWidthType: String, Codable {
    case `default`, veryNarrow, narrow, standard, wide
    case atMostVeryNarrow, atMostNarrow, atMostStandard, atMostWide
    case atLeastVeryNarrow, atLeastNarrow, atLeastStandard, atLeastWide
}
