import Foundation

// MARK: - Additional Missing Types

/// Represents the height setting for a card element.
enum HeightType: String, Codable {
    case auto
    case stretch
}

/// Represents the fallback behavior for an element.
enum FallbackType: String, Codable {
    case none
    case drop
    case content
}

// MARK: - AdaptiveCard Model

/// Represents an Adaptive Card that contains UI elements and actions.
class AdaptiveCard: Codable {
    var version: String
    var fallbackText: String?
    var backgroundImage: BackgroundImage?         // Defined in BackgroundImage.swift
    var refresh: Refresh?                         // Defined in Refresh.swift
    var authentication: Authentication?           // Defined in Authentication.swift
    var speak: String?
    var style: ContainerStyle                     // Defined in EnumMagic.swift
    var language: String?
    var verticalContentAlignment: VerticalContentAlignment // See alias above
    var height: HeightType
    var minHeight: UInt
    var rtl: Bool?
    var body: [BaseCardElement]                   // Defined in BaseCardElement.swift
    var actions: [BaseActionElement]              // Defined in BaseActionElement.swift
    var layouts: [Layout]                         // Defined in Layout.swift
    var selectAction: BaseActionElement?          // Defined in BaseActionElement.swift
    var requires: [String: SemanticVersion]       // Defined in SemanticVersion.swift
    var fallbackContent: BaseElement?             // Defined in BaseElement.swift
    var fallbackType: FallbackType

    /// Initializes an empty AdaptiveCard with default values.
    init(
        version: String = "1.0",
        fallbackText: String? = nil,
        backgroundImage: BackgroundImage? = nil,
        refresh: Refresh? = nil,
        authentication: Authentication? = nil,
        speak: String? = nil,
        style: ContainerStyle = .none,
        language: String? = nil,
        verticalContentAlignment: VerticalContentAlignment = .top,
        height: HeightType = .auto,
        minHeight: UInt = 0,
        rtl: Bool? = nil,
        body: [BaseCardElement] = [],
        actions: [BaseActionElement] = [],
        layouts: [Layout] = [],
        selectAction: BaseActionElement? = nil,
        requires: [String: SemanticVersion] = [:],
        fallbackContent: BaseElement? = nil,
        fallbackType: FallbackType = .none
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
    func serializeToJsonValue()  -> [String: Any] {
        var json: [String: Any] = [:]
        json[AdaptiveCardSchemaKey.version.rawValue] = version
        if let fallbackText = fallbackText {
            json[AdaptiveCardSchemaKey.fallbackText.rawValue] = fallbackText
        }
        if let backgroundImage = backgroundImage {
            json[AdaptiveCardSchemaKey.backgroundImage.rawValue] = backgroundImage.serializeToJsonValue()
        }
        if let refresh = refresh {
            json[AdaptiveCardSchemaKey.refresh.rawValue] = refresh.serializeToJson()
        }
        if let authentication = authentication {
            json[AdaptiveCardSchemaKey.authentication.rawValue] = try? authentication.serializeToJsonValue()
        }
        if let speak = speak {
            json[AdaptiveCardSchemaKey.speak.rawValue] = speak
        }
        json[AdaptiveCardSchemaKey.style.rawValue] = style.rawValue
        if let language = language {
            json[AdaptiveCardSchemaKey.language.rawValue] = language
        }
        json[AdaptiveCardSchemaKey.verticalContentAlignment.rawValue] = verticalContentAlignment.rawValue
        json[AdaptiveCardSchemaKey.height.rawValue] = height.rawValue
        json[AdaptiveCardSchemaKey.minHeight.rawValue] = minHeight
        if let rtl = rtl {
            json[AdaptiveCardSchemaKey.rtl.rawValue] = rtl
        }
        json[AdaptiveCardSchemaKey.body.rawValue] = body.map { $0.toJSON() }
        json[AdaptiveCardSchemaKey.actions.rawValue] = actions.map { $0.toJSON() }
        json[AdaptiveCardSchemaKey.layouts.rawValue] = layouts.map { $0.serializeToJsonValue() }
        if let selectAction = selectAction {
            json[AdaptiveCardSchemaKey.selectAction.rawValue] = selectAction.toJSON()
        }
        return json
    }
    
    /// Converts the card into a JSON string.
    func serialize() throws -> String {
        return try ParseUtil.jsonToString(serializeToJsonValue())
    }
    
    /// Deserializes an AdaptiveCard from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> AdaptiveCard {
        let version = json[AdaptiveCardSchemaKey.version.rawValue] as? String ?? "1.0"
        let fallbackText = json[AdaptiveCardSchemaKey.fallbackText.rawValue] as? String
        let backgroundImageJson = json[AdaptiveCardSchemaKey.backgroundImage.rawValue] as? [String: Any]
        let backgroundImage = try backgroundImageJson.map { try BackgroundImage.deserialize(from: $0) }
        let refreshJson = json[AdaptiveCardSchemaKey.refresh.rawValue] as? [String: Any]
        let refresh = try refreshJson.map { try Refresh.deserialize(from: $0) }
        let authenticationJson = json[AdaptiveCardSchemaKey.authentication.rawValue] as? [String: Any]
        let authentication = try authenticationJson.map { try Authentication.deserialize(from: $0) }
        let speak = json[AdaptiveCardSchemaKey.speak.rawValue] as? String
        let style = ContainerStyle(rawValue: json[AdaptiveCardSchemaKey.style.rawValue] as? String ?? "none") ?? .none
        let language = json[AdaptiveCardSchemaKey.language.rawValue] as? String
        let verticalContentAlignment = VerticalContentAlignment(rawValue: json[AdaptiveCardSchemaKey.verticalContentAlignment.rawValue] as? String ?? "top") ?? .top
        let height = HeightType(rawValue: json[AdaptiveCardSchemaKey.height.rawValue] as? String ?? "auto") ?? .auto
        let minHeight = json[AdaptiveCardSchemaKey.minHeight.rawValue] as? UInt ?? 0
        let rtl = json[AdaptiveCardSchemaKey.rtl.rawValue] as? Bool
        let bodyJson = json[AdaptiveCardSchemaKey.body.rawValue] as? [[String: Any]] ?? []
        let body = try bodyJson.map { try BaseCardElement.deserialize(from: $0) }
        let actionsJson = json[AdaptiveCardSchemaKey.actions.rawValue] as? [[String: Any]] ?? []
        let actions = try actionsJson.map { try BaseActionElement.deserialize(from: $0) }
        let layoutsJson = json[AdaptiveCardSchemaKey.layouts.rawValue] as? [[String: Any]] ?? []
        let layouts = try layoutsJson.map { try Layout.deserialize(from: $0) }
        var selectAction: BaseActionElement? = nil
        if let selectActionJson = json[AdaptiveCardSchemaKey.selectAction.rawValue] as? [String: Any] {
            selectAction = try BaseActionElement.deserialize(from: selectActionJson)
        }
        return AdaptiveCard(
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
    }
    
    /// Deserializes an AdaptiveCard from a JSON string.
    static func deserialize(from jsonString: String) throws -> AdaptiveCard {
        let jsonDict = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: jsonDict)
    }
}
