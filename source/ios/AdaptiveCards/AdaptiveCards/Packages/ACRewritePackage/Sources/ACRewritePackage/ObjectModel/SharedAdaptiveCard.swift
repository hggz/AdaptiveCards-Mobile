import Foundation

/// Represents an Adaptive Card that contains UI elements and actions.
class AdaptiveCard: Codable {
    var version: String
    var fallbackText: String?
    var backgroundImage: BackgroundImage?
    var refresh: Refresh?
    var authentication: Authentication?
    var speak: String?
    var style: ContainerStyle
    var language: String?
    var verticalContentAlignment: VerticalContentAlignment
    var height: HeightType
    var minHeight: UInt
    var rtl: Bool?
    var body: [BaseCardElement]
    var actions: [BaseActionElement]
    var layouts: [Layout]
    var selectAction: BaseActionElement?
    var requires: [String: SemanticVersion]
    var fallbackContent: BaseElement?
    var fallbackType: FallbackType

    /// Initializes an empty `AdaptiveCard` with default values.
    init(version: String = "1.0",
         fallbackText: String? = nil,
         backgroundImage: BackgroundImage? = nil,
         refresh: Refresh? = nil,
         authentication: Authentication? = nil,
         style: ContainerStyle = .none,
         speak: String? = nil,
         language: String? = nil,
         verticalContentAlignment: VerticalContentAlignment = .top,
         height: HeightType = .auto,
         minHeight: UInt = 0,
         body: [BaseCardElement] = [],
         actions: [BaseActionElement] = [],
         layouts: [Layout] = [],
         selectAction: BaseActionElement? = nil,
         requires: [String: SemanticVersion] = [:],
         fallbackContent: BaseElement? = nil,
         fallbackType: FallbackType = .none) {
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
        self.rtl = nil
        self.body = body
        self.actions = actions
        self.layouts = layouts
        self.selectAction = selectAction
        self.requires = requires
        self.fallbackContent = fallbackContent
        self.fallbackType = fallbackType
    }

    /// Serializes the card into a JSON dictionary.
    func serializeToJsonValue() -> [String: Any] {
        var json: [String: Any] = [:]
        json[AdaptiveCardSchemaKey.version.rawValue] = version
        if let fallbackText = fallbackText { json[AdaptiveCardSchemaKey.fallbackText.rawValue] = fallbackText }
        if let backgroundImage = backgroundImage { json[AdaptiveCardSchemaKey.backgroundImage.rawValue] = backgroundImage.serializeToJsonValue() }
        if let refresh = refresh { json[AdaptiveCardSchemaKey.refresh.rawValue] = refresh.serializeToJsonValue() }
        if let authentication = authentication { json[AdaptiveCardSchemaKey.authentication.rawValue] = authentication.serializeToJsonValue() }
        if let speak = speak { json[AdaptiveCardSchemaKey.speak.rawValue] = speak }
        json[AdaptiveCardSchemaKey.style.rawValue] = style.rawValue
        if let language = language { json[AdaptiveCardSchemaKey.language.rawValue] = language }
        json[AdaptiveCardSchemaKey.verticalContentAlignment.rawValue] = verticalContentAlignment.rawValue
        json[AdaptiveCardSchemaKey.height.rawValue] = height.rawValue
        json[AdaptiveCardSchemaKey.minHeight.rawValue] = minHeight
        if let rtl = rtl { json[AdaptiveCardSchemaKey.rtl.rawValue] = rtl }

        json[AdaptiveCardSchemaKey.body.rawValue] = body.map { $0.serializeToJsonValue() }
        json[AdaptiveCardSchemaKey.actions.rawValue] = actions.map { $0.serializeToJsonValue() }
        json[AdaptiveCardSchemaKey.layouts.rawValue] = layouts.map { $0.serializeToJsonValue() }

        if let selectAction = selectAction {
            json[AdaptiveCardSchemaKey.selectAction.rawValue] = selectAction.serializeToJsonValue()
        }

        return json
    }

    /// Converts the card to a JSON string.
    func serialize() throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: serializeToJsonValue(), options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Deserializes an `AdaptiveCard` from a JSON dictionary.
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
        let selectActionJson = json[AdaptiveCardSchemaKey.selectAction.rawValue] as? [String: Any]
        let selectAction = try selectActionJson.map { try BaseActionElement.deserialize(from: $0) }

        return AdaptiveCard(
            version: version,
            fallbackText: fallbackText,
            backgroundImage: backgroundImage,
            refresh: refresh,
            authentication: authentication,
            style: style,
            speak: speak,
            language: language,
            verticalContentAlignment: verticalContentAlignment,
            height: height,
            minHeight: minHeight,
            body: body,
            actions: actions,
            layouts: layouts,
            selectAction: selectAction,
            requires: [:],
            fallbackContent: nil,
            fallbackType: .none
        )
    }
}
