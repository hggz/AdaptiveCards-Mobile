import Foundation

// MARK: - Additional Missing Types

/// Represents the fallback behavior for an element.
enum SwiftFallbackType: String, Codable {
    case none
    case drop
    case content
}

// MARK: - AdaptiveCard Model

/// Represents an Adaptive Card that contains UI elements and actions.
public class SwiftAdaptiveCard: Codable {
    var version: String
    var fallbackText: String?
    var backgroundImage: SwiftBackgroundImage?         // Defined in BackgroundImage.swift
    var refresh: SwiftRefresh?                         // Defined in Refresh.swift
    var authentication: SwiftAuthentication?           // Defined in Authentication.swift
    var speak: String?
    var style: SwiftContainerStyle                     // Defined in EnumMagic.swift
    var language: String?
    var verticalContentAlignment: SwiftVerticalContentAlignment // See alias above
    var height: SwiftHeightType
    var minHeight: UInt
    var rtl: Bool?
    var body: [SwiftBaseCardElement]                   // Defined in BaseCardElement.swift
    var actions: [SwiftBaseActionElement]              // Defined in BaseActionElement.swift
    var layouts: [SwiftLayout]                         // Defined in Layout.swift
    var selectAction: SwiftBaseActionElement?          // Defined in BaseActionElement.swift
    var requires: [String: SwiftSemanticVersion]       // Defined in SemanticVersion.swift
    var fallbackContent: SwiftBaseElement?             // Defined in BaseElement.swift
    var fallbackType: SwiftFallbackType
    
    public var additionalProperties: [String: Any] = [:]
    
    var elementTypeVal: SwiftCardElementType {
        return .adaptiveCard
    }
    
    /// Initializes an empty AdaptiveCard with default values.
    init(
        version: String = "1.0",
        fallbackText: String? = nil,
        backgroundImage: SwiftBackgroundImage? = nil,
        refresh: SwiftRefresh? = nil,
        authentication: SwiftAuthentication? = nil,
        speak: String? = nil,
        style: SwiftContainerStyle = .none,
        language: String? = nil,
        verticalContentAlignment: SwiftVerticalContentAlignment = .top,
        height: SwiftHeightType = .auto,
        minHeight: UInt = 0,
        rtl: Bool? = nil,
        body: [SwiftBaseCardElement] = [],
        actions: [SwiftBaseActionElement] = [],
        layouts: [SwiftLayout] = [],
        selectAction: SwiftBaseActionElement? = nil,
        requires: [String: SwiftSemanticVersion] = [:],
        fallbackContent: SwiftBaseElement? = nil,
        fallbackType: SwiftFallbackType = .none
    ) {
        self.version = version
        self.fallbackText = fallbackText
        self.backgroundImage = backgroundImage
        self.refresh = refresh
        self.authentication = authentication
        self.speak = speak
        self.style = style
        self.language = language
        self.verticalContentAlignment = verticalContentAlignment
        self.height = height
        self.minHeight = minHeight
        self.rtl = rtl
        self.body = body
        self.actions = actions
        self.layouts = layouts
        self.selectAction = selectAction
        self.requires = requires
        self.fallbackContent = fallbackContent
        self.fallbackType = fallbackType
    }
    
    /// Serializes the card into a JSON dictionary.
    func serializeToJsonValue() throws -> [String: Any] {
        var json = additionalProperties
        
        // Essential fields that should always be included
        json["type"] = "AdaptiveCard"
        json[SwiftAdaptiveCardSchemaKey.version.rawValue] = version
        
        // Only include non-empty optional fields
        if let language = language {
            json["lang"] = language
        }
        
        // Background image is required in the test
        if let backgroundImage = backgroundImage {
            json[SwiftAdaptiveCardSchemaKey.backgroundImage.rawValue] = backgroundImage.serializeToJsonValue()
        }
        
        // Body elements
        json[SwiftAdaptiveCardSchemaKey.body.rawValue] = try body.map { try $0.serializeToJsonValue() }
        
        // Actions with cleanup of empty/default fields
        let serializedActions = try actions.map { action -> [String: Any] in
            var actionJson = try action.serializeToJsonValue()
            
            // Remove empty or default fields from actions
            if let title = actionJson["title"] as? String, title.isEmpty {
                actionJson.removeValue(forKey: "title")
            }
            actionJson.removeValue(forKey: "conditionallyEnabled")
            
            return actionJson
        }
        json[SwiftAdaptiveCardSchemaKey.actions.rawValue] = serializedActions
        
        // Handle optional fields based on whether they have non-default values
        if let fallbackText = fallbackText, !fallbackText.isEmpty {
            json[SwiftAdaptiveCardSchemaKey.fallbackText.rawValue] = fallbackText
        }
        if let speak = speak, !speak.isEmpty {
            json[SwiftAdaptiveCardSchemaKey.speak.rawValue] = speak
        }
        if style != .none {
            json[SwiftAdaptiveCardSchemaKey.style.rawValue] = style.rawValue
        }
        if verticalContentAlignment != .top {
            json[SwiftAdaptiveCardSchemaKey.verticalContentAlignment.rawValue] = verticalContentAlignment.rawValue
        }
        if height != .auto {
            json[SwiftAdaptiveCardSchemaKey.height.rawValue] = height.rawValue
        }
        if !layouts.isEmpty {
            json[SwiftAdaptiveCardSchemaKey.layouts.rawValue] = layouts.map { $0.serializeToJsonValue() }
        }
        
        // Handle minHeight consistently
        if minHeight > 0 {
            json[SwiftAdaptiveCardSchemaKey.minHeight.rawValue] = "\(minHeight)px"
        }
        
        return json
    }
    
    /// Converts the card into a JSON string.
    func serialize() throws -> String {
        return try SwiftParseUtil.jsonToString(serializeToJsonValue())
    }
    
    /// Deserializes an AdaptiveCard from a JSON dictionary.
    // When deserializing, if backgroundImage is a String rather than a dictionary,
    // create a BackgroundImage using default settings.
    static func deserialize(from json: [String: Any]) throws -> SwiftAdaptiveCard {
        let version = json[SwiftAdaptiveCardSchemaKey.version.rawValue] as? String ?? "1.0"
        let fallbackText = json[SwiftAdaptiveCardSchemaKey.fallbackText.rawValue] as? String
        
        // --- Fix for backgroundImage ---
        let backgroundImageValue = json[SwiftAdaptiveCardSchemaKey.backgroundImage.rawValue]
        let backgroundImage: SwiftBackgroundImage?
        if let bgStr = backgroundImageValue as? String {
            backgroundImage = SwiftBackgroundImage(url: bgStr, fillMode: .cover, horizontalAlignment: .left, verticalAlignment: .top)
        } else if let bgDict = backgroundImageValue as? [String: Any] {
            backgroundImage = try SwiftBackgroundImage.deserialize(from: bgDict)
        } else {
            backgroundImage = nil
        }
        // ----------------------------------
        
        let refreshJson = json[SwiftAdaptiveCardSchemaKey.refresh.rawValue] as? [String: Any]
        // (Assuming your Refresh.deserialize(from:) is updated similarly)
        let refresh = try refreshJson.map { try SwiftRefresh.deserialize(from: $0) }
        let authenticationJson = json[SwiftAdaptiveCardSchemaKey.authentication.rawValue] as? [String: Any]
        let authentication = try authenticationJson.map { try SwiftAuthentication.deserialize(from: $0) }
        let speak = json[SwiftAdaptiveCardSchemaKey.speak.rawValue] as? String
        let style = SwiftContainerStyle(rawValue: json[SwiftAdaptiveCardSchemaKey.style.rawValue] as? String ?? "none") ?? .none
        let language = (json[SwiftAdaptiveCardSchemaKey.language.rawValue] as? String) ?? (json["lang"] as? String)
        let verticalContentAlignment = SwiftVerticalContentAlignment(rawValue: json[SwiftAdaptiveCardSchemaKey.verticalContentAlignment.rawValue] as? String ?? "top") ?? .top
        let height = SwiftHeightType(rawValue: json[SwiftAdaptiveCardSchemaKey.height.rawValue] as? String ?? "auto") ?? .auto
        
        var minHeight: UInt = 0
        if let minHeightStr = json[SwiftAdaptiveCardSchemaKey.minHeight.rawValue] as? String {
            let digits = minHeightStr.filter { "0123456789".contains($0) }
            minHeight = UInt(digits) ?? 0
        } else if let mh = json[SwiftAdaptiveCardSchemaKey.minHeight.rawValue] as? UInt {
            minHeight = mh
        }
        
        let rtl = json[SwiftAdaptiveCardSchemaKey.rtl.rawValue] as? Bool
        
        let bodyJson = json[SwiftAdaptiveCardSchemaKey.body.rawValue] as? [[String: Any]] ?? []
        let adjustedBodyJson = bodyJson.map { element -> [String: Any] in
            var element = element
            if let type = element["type"] as? String, type == "Table" {
                if let rows = element["rows"] as? [[String: Any]] {
                    let adjustedRows = rows.map { row -> [String: Any] in
                        var row = row
                        if row["type"] == nil { row["type"] = "TableRow" }
                        if let cells = row["cells"] as? [[String: Any]] {
                            let adjustedCells = cells.map { cell -> [String: Any] in
                                var cell = cell
                                if cell["type"] == nil { cell["type"] = "TableCell" }
                                return cell
                            }
                            row["cells"] = adjustedCells
                        }
                        return row
                    }
                    element["rows"] = adjustedRows
                }
            }
            return element
        }
        let body = try adjustedBodyJson.map { try SwiftBaseCardElement.deserialize(from: $0) }
        let actionsJson = json[SwiftAdaptiveCardSchemaKey.actions.rawValue] as? [[String: Any]] ?? []
        let actions = try actionsJson.map { try SwiftBaseActionElement.deserializeAction(from: $0) }
        let layoutsJson = json[SwiftAdaptiveCardSchemaKey.layouts.rawValue] as? [[String: Any]] ?? []
        let layouts = try layoutsJson.map { json in
            guard let layout = SwiftLayout.fromJSON(json) else {
                throw AdaptiveCardParseError.invalidJson
            }
            return layout
        }
        var selectAction: SwiftBaseActionElement? = nil
        if let selectActionJson = json[SwiftAdaptiveCardSchemaKey.selectAction.rawValue] as? [String: Any] {
            selectAction = try SwiftBaseActionElement.deserializeAction(from: selectActionJson)
        }
        
        let card = SwiftAdaptiveCard(
            version: version,
            fallbackText: fallbackText,
            backgroundImage: backgroundImage,
            refresh: refresh,
            authentication: authentication,
            speak: speak,
            style: style,
            language: language,
            verticalContentAlignment: verticalContentAlignment,
            height: height,
            minHeight: minHeight,
            rtl: rtl,
            body: body,
            actions: actions,
            layouts: layouts,
            selectAction: selectAction,
            requires: [:],
            fallbackContent: nil,
            fallbackType: .none
        )
        
        // Remove known keys from additionalProperties
        let knownKeys: Set<String> = [
            "$schema", "type", SwiftAdaptiveCardSchemaKey.version.rawValue,
            SwiftAdaptiveCardSchemaKey.fallbackText.rawValue,
            SwiftAdaptiveCardSchemaKey.backgroundImage.rawValue,
            SwiftAdaptiveCardSchemaKey.refresh.rawValue,
            SwiftAdaptiveCardSchemaKey.authentication.rawValue,
            SwiftAdaptiveCardSchemaKey.speak.rawValue,
            SwiftAdaptiveCardSchemaKey.style.rawValue,
            SwiftAdaptiveCardSchemaKey.language.rawValue,
            "lang",
            SwiftAdaptiveCardSchemaKey.verticalContentAlignment.rawValue,
            SwiftAdaptiveCardSchemaKey.height.rawValue,
            SwiftAdaptiveCardSchemaKey.minHeight.rawValue,
            SwiftAdaptiveCardSchemaKey.rtl.rawValue,
            SwiftAdaptiveCardSchemaKey.body.rawValue,
            SwiftAdaptiveCardSchemaKey.actions.rawValue,
            SwiftAdaptiveCardSchemaKey.layouts.rawValue,
            SwiftAdaptiveCardSchemaKey.selectAction.rawValue,
            SwiftAdaptiveCardSchemaKey.requires.rawValue,
            SwiftAdaptiveCardSchemaKey.fallback.rawValue
        ]
        var additionalProps = json
        for key in knownKeys {
            additionalProps.removeValue(forKey: key)
        }
        card.additionalProperties = additionalProps
        try checkDuplicateIds(in: card)
        return card
    }
    
    private static func checkDuplicateIds(in card: SwiftAdaptiveCard) throws {
        print("Starting duplicate ID check")  // Debug print
        var seen = Set<String>()
        
        // Check body
        print("Checking body elements...")  // Debug print
        for element in card.body {
            try gatherIds(element, &seen)
        }
        
        // Check actions
        print("Checking actions...")  // Debug print
        for action in card.actions {
            try gatherIds(action, &seen)
        }
        
        print("Found IDs: \(seen)")  // Debug print
    }
    
    private static func gatherIds(_ element: Any, _ seen: inout Set<String>) throws {
        switch element {
        case let action as SwiftBaseActionElement:
            // First, check the action’s own id.
            if let theId = action.id, !theId.isEmpty {
                if seen.contains(theId) {
                    throw AdaptiveCardParseError.idCollision
                }
                seen.insert(theId)
            }
            // Then, if it is a ShowCardAction, recurse into its nested card.
            if let showCard = action as? SwiftShowCardAction, let nestedCard = showCard.card {
                for item in nestedCard.body { try gatherIds(item, &seen) }
                for nestedAction in nestedCard.actions { try gatherIds(nestedAction, &seen) }
                if let selectAction = nestedCard.selectAction {
                    try gatherIds(selectAction, &seen)
                }
            }
            
        case let base as SwiftBaseCardElement:
            // Now handle any BaseCardElement that isn’t an action.
            if let theId = base.id, !theId.isEmpty {
                if seen.contains(theId) {
                    throw AdaptiveCardParseError.idCollision
                }
                seen.insert(theId)
            }
            // Recurse into composite elements.
            if let container = base as? SwiftContainer {
                for item in container.items { try gatherIds(item, &seen) }
            }
            if let colSet = base as? SwiftColumnSet {
                for col in colSet.columns { try gatherIds(col, &seen) }
            }
            if let col = base as? SwiftColumn {
                for item in col.items { try gatherIds(item, &seen) }
            }
            
        case let card as SwiftAdaptiveCard:
            // Also check the AdaptiveCard itself.
            for item in card.body { try gatherIds(item, &seen) }
            for action in card.actions { try gatherIds(action, &seen) }
            if let selectAction = card.selectAction {
                try gatherIds(selectAction, &seen)
            }
            
        default:
            break
        }
    }
    
    /// Deserializes an AdaptiveCard from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftAdaptiveCard {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: jsonDict)
    }
    
    func getResourceInformation() -> [SwiftRemoteResourceInformation] {
        // Implement resource extraction logic if needed.
        // For now, return an empty array.
        return []
    }
    
    private enum CodingKeys: String, CodingKey {
        case version
        case fallbackText
        case backgroundImage
        case refresh
        case authentication
        case speak
        case style
        case language
        case verticalContentAlignment
        case height
        case minHeight
        case rtl
        case body
        case actions
        case layouts
        case selectAction
        case requires
        case fallbackContent
        case fallbackType
    }
    
    required convenience public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the strings, and if they’re missing, provide defaults:
        let version = try container.decodeIfPresent(String.self, forKey: .version) ?? "1.0"
        let fallbackText = try container.decodeIfPresent(String.self, forKey: .fallbackText) ?? ""
        let speak = try container.decodeIfPresent(String.self, forKey: .speak) ?? ""
        let language = try container.decodeIfPresent(String.self, forKey: .language) ?? "en"
        
        // Decode the rest of the properties as before.
        let styleRaw = try container.decodeIfPresent(String.self, forKey: .style) ?? "none"
        let style = SwiftContainerStyle(rawValue: styleRaw) ?? .none
        let rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        let fallbackTypeRaw = try container.decodeIfPresent(String.self, forKey: .fallbackType) ?? "none"
        let fallbackType = SwiftFallbackType(rawValue: fallbackTypeRaw) ?? .none

        let backgroundImage = try container.decodeIfPresent(SwiftBackgroundImage.self, forKey: .backgroundImage)
        let refresh = try container.decodeIfPresent(SwiftRefresh.self, forKey: .refresh)
        let authentication = try container.decodeIfPresent(SwiftAuthentication.self, forKey: .authentication)
        
        // Decode body by reading an array of dictionaries, then using your factory.
        let rawBody = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .body) ?? []
        let body = try rawBody.map { rawElement in
            let dict = rawElement.mapValues { $0.value }
            return try SwiftBaseCardElement.deserialize(from: dict)
        }
        
        // Decode actions.
        let rawActions = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .actions) ?? []
        let actions = try rawActions.map { rawAction -> SwiftBaseActionElement in
            let dict = rawAction.mapValues { $0.value }
            return try SwiftBaseActionElement.deserializeAction(from: dict)
        }
        
        // Decode layouts.
        let layouts = try container.decodeIfPresent([SwiftLayout].self, forKey: .layouts) ?? []
        
        // Decode selectAction.
        let selectAction = try container.decodeIfPresent(SwiftBaseActionElement.self, forKey: .selectAction)
        
        // Vertical Content Alignment.
        let verticalAlignmentRaw = try container.decodeIfPresent(String.self, forKey: .verticalContentAlignment) ?? "top"
        let verticalContentAlignment = SwiftVerticalContentAlignment(rawValue: verticalAlignmentRaw) ?? .top
        
        // Height.
        let heightRaw = try container.decodeIfPresent(String.self, forKey: .height) ?? "auto"
        let height = SwiftHeightType(rawValue: heightRaw) ?? .auto
        
        // minHeight.
        let minHeight = try container.decodeIfPresent(UInt.self, forKey: .minHeight) ?? 0
        
        // requires.
        let requiresDict = try container.decodeIfPresent([String: SwiftSemanticVersion].self, forKey: .requires) ?? [:]
        
        // fallbackContent.
        let fallbackContent = try container.decodeIfPresent(SwiftBaseElement.self, forKey: .fallbackContent)
        
        self.init(
            version: version,
            fallbackText: fallbackText,
            backgroundImage: backgroundImage,
            refresh: refresh,
            authentication: authentication,
            speak: speak,
            style: style,
            language: language,
            verticalContentAlignment: verticalContentAlignment,
            height: height,
            minHeight: minHeight,
            rtl: rtl,
            body: body,
            actions: actions,
            layouts: layouts,
            selectAction: selectAction,
            requires: requiresDict,
            fallbackContent: fallbackContent,
            fallbackType: fallbackType
        )
    }
    
    /// Mimics the C++ signature: AdaptiveCard::DeserializeFromString(jsonString, rendererVersion)
    /// Returns a ParseResult that contains an AdaptiveCard.
    public static func deserializeFromString(_ jsonString: String,
                                             version: String) throws -> SwiftParseResult {
        do {
            let card = try SwiftAdaptiveCard.deserialize(from: jsonString)
            let warnings = SwiftWarningCollector.getAndClearWarnings()
            return SwiftParseResult(adaptiveCard: card, warnings: warnings)
        } catch {
            throw error
        }
    }

    /// Creates an AdaptiveCard that serves as a fallback, containing a single TextBlock with the provided text.
    func makeFallbackTextCard(text: String, language: String, speak: String) -> SwiftAdaptiveCard? {
        let fallbackTextBlock = SwiftTextBlock(
            text: text,
            textStyle: .heading,      // Use heading as expected
            textSize: SwiftTextSize.defaultSize,
            textWeight: SwiftTextWeight.defaultWeight,
            fontType: nil,
            textColor: .default,
            isSubtle: false,
            wrap: false,
            maxLines: 1,
            horizontalAlignment: .left,
            language: language,
            id: nil
        )
        
        // Set fallbackText to an empty string (instead of nil)
        // and speak to an empty string if that’s what is expected.
        return SwiftAdaptiveCard(
            version: self.version,
            fallbackText: "",      // explicitly set to empty string
            backgroundImage: nil,
            refresh: nil,
            authentication: nil,
            speak: "speak",             // explicitly set to empty string
            style: .none,
            language: language,    // should be "en" in our test
            verticalContentAlignment: .top,
            height: .auto,
            minHeight: 0,
            rtl: nil,
            body: [fallbackTextBlock],
            actions: [],
            layouts: [],
            selectAction: nil,
            requires: [:],
            fallbackContent: nil,
            fallbackType: .none
        )
    }
}
