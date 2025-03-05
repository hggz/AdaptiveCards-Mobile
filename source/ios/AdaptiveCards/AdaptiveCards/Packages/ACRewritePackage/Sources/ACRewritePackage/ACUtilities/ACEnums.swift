//
//  ACEnums.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/18/24.
//


import Foundation

enum AdaptiveCardSchemaKey: String, Codable {
    case accent = "accent"
    case action = "action"
    case actionAlignment = "actionAlignment"
    case actionMode = "actionMode"
    case actionRole = "role"
    case actionSet = "ActionSet"
    case actionSetConfig = "actionSetConfig"
    case actions = "actions"
    case actionsOrientation = "actionsOrientation"
    case adaptiveCard = "adaptiveCard"
    case allowCustomStyle = "allowCustomStyle"
    case allowInlinePlayback = "allowInlinePlayback"
    case altText = "altText"
    case name = "name"
    case associatedInputs = "associatedInputs"
    case attention = "attention"
    case authentication = "authentication"
    case backgroundColor = "backgroundColor"
    case backgroundImage = "backgroundImage"
    case backgroundImageUrl = "backgroundImageUrl"
    case baseCardElement = "baseCardElement"
    case baseContainerStyle = "baseContainerStyle"
    case badge = "badge"
    case bleed = "bleed"
    case body = "body"
    case bolder = "bolder"
    case borderColor = "borderColor"
    case bottom = "bottom"
    case buttonSpacing = "buttonSpacing"
    case buttons = "buttons"
    case captionSources = "captionSources"
    case card = "card"
    case cellSpacing = "cellSpacing"
    case cells = "cells"
    case center = "center"
    case choiceSet = "choiceSet"
    case choices = "choices"
    case choicesData = "choices.data"
    case choicesDataType = "choicesDataTyp"
    case color = "color"
    case colorConfig = "colorConfig"
    case column = "column"
    case columnHeader = "columnHeader"
    case columnSet = "columnSet"
    case columns = "columns"
    case conditionallyEnabled = "conditionallyEnabled"
    case connectionName = "connectionName"
    case container = "container"
    case containerStyles = "containerStyles"
    case borderWidth = "borderWidth"
    case cornerRadius = "cornerRadius"
    case dark = "dark"
    case data = "data"
    case dataQuery = "Data.Query"
    case dataset = "dataset"
    case dateInput = "dateInput"
    case `default` = "default"
    case defaultPoster = "defaultPoster"
    case count = "count"
    case description = "description"
    case elementId = "elementId"
    case emphasis = "emphasis"
    case errorMessage = "errorMessage"
    case extraLarge = "extraLarge"
    case factSet = "factSet"
    case facts = "facts"
    case fallback = "fallback"
    case fallbackText = "fallbackText"
    case fillMode = "fillMode"
    case firstRowAsHeaders = "firstRowAsHeaders"
    case fontFamily = "fontFamily"
    case fontSizes = "fontSizes"
    case fontType = "fontType"
    case fontTypes = "fontTypes"
    case fontWeights = "fontWeights"
    case foregroundColor = "foregroundColor"
    case foregroundColors = "foregroundColors"
    case good = "good"
    case gridStyle = "gridStyle"
    case heading = "heading"
    case headingLevel = "headingLevel"
    case height = "height"
    case highlight = "highlight"
    case highlightColor = "highlightColor"
    case highlightColors = "highlightColors"
    case horizontalAlignment = "horizontalAlignment"
    case horizontalCellContentAlignment = "horizontalCellContentAlignment"
    case hostWidthBreakpoints = "hostWidthBreakpoints"
    case iconPlacement = "iconPlacement"
    case iconSize = "iconSize"
    case iconUrl = "iconUrl"
    case id = "id"
    case image = "image"
    case icon = "icon"
    case imageBaseUrl = "imageBaseUrl"
    case imageSet = "imageSet"
    case imageSize = "imageSize"
    case imageSizes = "imageSizes"
    case images = "images"
    case inlineAction = "inlineAction"
    case inlineTopMargin = "inlineTopMargin"
    case inlines = "inlines"
    case inputSpacing = "inputSpacing"
    case inputs = "inputs"
    case isEnabled = "isEnabled"
    case isMultiSelect = "isMultiSelect"
    case isMultiline = "isMultiline"
    case showBorder = "showBorder"
    case roundedCorners = "roundedCorners"
    case isRequired = "isRequired"
    case isSelected = "isSelected"
    case isSubtle = "isSubtle"
    case isVisible = "isVisible"
    case italic = "italic"
    case items = "items"
    case label = "label"
    case language = "lang"
    case large = "large"
    case left = "left"
    case light = "light"
    case lighter = "lighter"
    case lineColor = "lineColor"
    case lineThickness = "lineThickness"
    case max = "max"
    case maxActions = "maxActions"
    case maxImageHeight = "maxImageHeight"
    case maxLength = "maxLength"
    case maxLines = "maxLines"
    case maxWidth = "maxWidth"
    case media = "media"
    case medium = "medium"
    case metaData = "metaData"
    case method = "method"
    case mimeType = "mimeType"
    case min = "min"
    case minHeight = "minHeight"
    case mode = "mode"
    case monospace = "monospace"
    case narrow = "narrow"
    case numberInput = "numberInput"
    case ratingInput = "ratingInput"
    case ratingLabel = "ratingLabel"
    case optionalInputs = "optionalInputs"
    case padding = "padding"
    case placeholder = "placeholder"
    case playButton = "playButton"
    case poster = "poster"
    case providerId = "providerId"
    case refresh = "refresh"
    case regex = "regex"
    case `repeat` = "repeat"
    case repeatHorizontally = "repeatHorizontally"
    case repeatVertically = "repeatVertically"
    case requiredInputs = "requiredInputs"
    case requires = "requires"
    case richTextBlock = "richTextBlock"
    case right = "right"
    case rows = "rows"
    case rtl = "rtl"
    case schema = "$schema"
    case selectAction = "selectAction"
    case separator = "separator"
    case showActionMode = "showActionMode"
    case showCard = "showCard"
    case showCardActionConfig = "showCardActionConfig"
    case showGridLines = "showGridLines"
    case size = "size"
    case small = "small"
    case sources = "sources"
    case spacing = "spacing"
    case spacingDefinition = "spacingDefinition"
    case speak = "speak"
    case standard = "standard"
    case stretch = "stretch"
    case strikethrough = "strikethrough"
    case style = "style"
    case subtle = "subtle"
    case suffix = "suffix"
    case supportsInteractivity = "supportsInteractivity"
    case table = "table"
    case tableCell = "tableCell"
    case tableRow = "tableRow"
    case targetElements = "targetElements"
    case targetInputIds = "targetInputIds"
    case targetWidth = "targetWidth"
    case text = "text"
    case textBlock = "textBlock"
    case textConfig = "textConfig"
    case textInput = "textInput"
    case textStyles = "textStyles"
    case marigoldColor = "marigoldColor"
    case neutralColor = "neutralColor"
    case filledStar = "filledStar"
    case emptyStar = "emptyStar"
    case ratingTextColor = "ratingTextColor"
    case countTextColor = "countTextColor"
    case textWeight = "textWeight"
    case thickness = "thickness"
    case timeInput = "timeInput"
    case title = "title"
    case toggleInput = "toggleInput"
    case layout = "Layout"
    case itemFit = "itemFit"
    case rowSpacing = "rowSpacing"
    case columnSpacing = "columnSpacing"
    case itemWidth = "itemWidth"
    case minItemWidth = "minItemWidth"
    case maxItemWidth = "maxItemWidth"
    case horizontalItemsAlignment = "horizontalItemsAlignment"
    case row = "row"
    case rowSpan = "rowSpan"
    case columnSpan = "columnSpan"
    case areaGridName = "grid.area"
    case areas = "areas"
    case layouts = "layouts"
    case tokenExchangeResource = "tokenExchangeResource"
    case tooltip = "tooltip"
    case top = "top"
    case type = "type"
    case underline = "underline"
    case uri = "uri"
    case url = "url"
    case userIds = "userIds"
    case value = "value"
    case valueChangedAction = "valueChangedAction"
    case valueChangedActionType = "valueChangedActionType"
    case valueOff = "valueOff"
    case valueOn = "valueOn"
    case verb = "verb"
    case veryNarrow = "veryNarrow"
    case version = "version"
    case verticalAlignment = "verticalAlignment"
    case verticalCellContentAlignment = "verticalCellContentAlignment"
    case verticalContentAlignment = "verticalContentAlignment"
    case warning = "warning"
    case webUrl = "webUrl"
    case weight = "weight"
    case width = "width"
    case compoundButton = "compoundButton"
    case wrap = "wrap"
}

enum SwiftACCardElementType: String, Codable {
    case actionSet = "ActionSet"
    case adaptiveCard = "AdaptiveCard"
    case choiceSetInput = "Input.ChoiceSet"
    case column = "Column"
    case columnSet = "ColumnSet"
    case container = "Container"
    case custom = "Custom"
    case dateInput = "Input.Date"
    case fact = "Fact"
    case factSet = "FactSet"
    case image = "Image"
    case icon = "Icon"
    case imageSet = "ImageSet"
    case media = "Media"
    case numberInput = "Input.Number"
    case ratingInput = "Input.Rating"
    case ratingLabel = "Rating"
    case richTextBlock = "RichTextBlock"
    case table = "Table"
    case tableCell = "TableCell"
    case tableRow = "TableRow"
    case textBlock = "TextBlock"
    case textInput = "Input.Text"
    case timeInput = "Input.Time"
    case toggleInput = "Input.Toggle"
    case compoundButton = "CompoundButton"
    case unknown = "Unknown"
}

enum SwiftACActionType: String, Codable {
    case unsupported = "Unsupported"
    case execute = "Action.Execute"
    case openUrl = "Action.OpenUrl"
    case showCard = "Action.ShowCard"
    case submit = "Action.Submit"
    case toggleVisibility = "Action.ToggleVisibility"
    case custom = "Custom"
    case unknownAction = "UnknownAction"
    case overflow = "Overflow"
}

enum SwiftACHeightType: String, Codable {
    case auto = "Auto"
    case stretch = "Stretch"
}

enum RatingSize: String, Codable {
    case medium = "medium"
    case large = "large"
}

enum RatingColor: String, Codable {
    case neutral = "neutral"
    case marigold = "marigold"
}

enum RatingStyle: String, Codable {
    case `default` = "default"
    case compact = "compact"
}

enum SwiftACSpacing: String, Codable {
    case `default` = "default"
    case none = "none"
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
    case padding = "padding"
}

enum SeparatorThickness: String, Codable {
    case `default` = "default"
    case thick = "thick"
}

enum SwiftACImageStyle: String, Codable {
    case `default` = "default"
    case person = "person"
    case roundedCorners = "roundedCorners"
}

enum SwiftACIconSize: String, Codable {
    case xxSmall = "xxSmall"
    case xSmall = "xSmall"
    case small = "Small"
    case standard = "Standard"
    case medium = "Medium"
    case large = "Large"
    case xLarge = "xLarge"
    case xxLarge = "xxLarge"
}

enum SwiftACIconStyle: String, Codable {
    case regular = "Regular"
    case filled = "Filled"
}

enum SwiftACVerticalAlignment: String, Codable {
    case top = "top"
    case center = "center"
    case bottom = "bottom"
}

enum SwiftACImageFillMode: String, Codable {
    case cover = "cover"
    case repeatHorizontally = "repeatHorizontally"
    case repeatVertically = "repeatVertically"
    case `repeat` = "repeat"
}

enum ItemFit: String, Codable {
    case fit = "Fit"
    case fill = "Fill"
}

enum LayoutContainerType: String, Codable {
    case none = "Layout.None"
    case stack = "Layout.Stack"
    case flow = "Layout.Flow"
    case areaGrid = "Layout.AreaGrid"
}

enum SwiftACImageSize: String, Codable {
    case auto = "auto"
    case large = "Large"
    case medium = "Medium"
    case small = "Small"
    case stretch = "Stretch"
}

enum SwiftACHorizontalAlignment: String, Codable {
    case center = "center"
    case left = "left"
    case right = "right"
}

enum SwiftACForegroundColor: String, Codable {
    case accent = "Accent"
    case attention = "Attention"
    case dark = "Dark"
    case `default` = "default"
    case good = "Good"
    case light = "Light"
    case warning = "Warning"
}

enum SwiftACTextStyle: String, Codable {
    case `default` = "default"
    case heading = "Heading"
}

enum SwiftACTextWeight: String, Codable {
    case bolder = "bolder"
    case lighter = "Lighter"
    case `default` = "default"
}

enum SwiftACTextSize: String, Codable {
    case extraLarge = "ExtraLarge"
    case large = "large"
    case medium = "Medium"
    case `default` = "default"
    case small = "Small"
}

enum SwiftACFontType: String, Codable {
    case `default` = "Default"
    case monospace = "Monospace"
    case display = "display"
}

enum SwiftACActionsOrientation: String, Codable {
    case horizontal = "Horizontal"
    case vertical = "Vertical"
}

enum SwiftACActionMode: String, Codable {
    case inline = "Inline"
    case popup = "Popup"
}

enum SwiftACActionRole: String, Codable {
    case button = "Button"
    case link = "Link"
    case tab = "Tab"
    case menu = "Menu"
    case menuItem = "MenuItem"
}

enum SwiftACAssociatedInputs: String, Codable {
    case auto = "Auto"
    case none = "None"
}

enum SwiftACChoiceSetStyle: String, Codable {
    case compact = "Compact"
    case expanded = "Expanded"
    case filtered = "Filtered"
}

enum SwiftACTextInputStyle: String, Codable {
    case email = "Email"
    case tel = "Tel"
    case text = "Text"
    case url = "Url"
    case password = "Password"
}

enum SwiftACContainerStyle: String, Codable {
    case `default` = "default"
    case emphasis = "emphasis"
    case good = "Good"
    case attention = "Attention"
    case warning = "Warning"
    case accent = "Accent"
    case none = "none"
    case text = "text"
}

enum SwiftACActionAlignment: String, Codable {
    case left = "Left"
    case center = "Center"
    case right = "Right"
    case stretch = "Stretch"
}

enum SwiftACIconPlacement: String, Codable {
    case aboveTitle = "AboveTitle"
    case leftOfTitle = "LeftOfTitle"
}

enum SwiftACVerticalContentAlignment: String, Codable {
    case top = "Top"
    case center = "Center"
    case bottom = "Bottom"
}

enum SwiftACInlineElementType: String, Codable {
    case textRun = "TextRun"
}

enum SwiftACMode: String, Codable {
    case primary = "primary"
    case secondary = "secondary"
}

enum SwiftACErrorStatusCode: String, Codable {
    case invalidJson = "InvalidJson"
    case renderFailed = "RenderFailed"
    case requiredPropertyMissing = "RequiredPropertyMissing"
    case invalidPropertyValue = "InvalidPropertyValue"
    case unsupportedParserOverride = "UnsupportedParserOverride"
    case idCollision = "IdCollision"
    case customError = "CustomError"
}

enum SwiftACTargetWidthType: String, Codable {
    case `default` = "Default"
    case veryNarrow = "veryNarrow"
    case narrow = "narrow"
    case standard = "standard"
    case wide = "wide"
    case atMostVeryNarrow = "atMost:veryNarrow"
    case atMostNarrow = "atMost:narrow"
    case atMostStandard = "atMost:standard"
    case atMostWide = "atMost:wide"
    case atLeastVeryNarrow = "atLeast:veryNarrow"
    case atLeastNarrow = "atLeast:narrow"
    case atLeastStandard = "atLeast:standard"
    case atLeastWide = "atLeast:wide"
}

enum SwiftACValueChangedActionType: String, Codable {
    case resetInputs = "Action.ResetInputs"
}
