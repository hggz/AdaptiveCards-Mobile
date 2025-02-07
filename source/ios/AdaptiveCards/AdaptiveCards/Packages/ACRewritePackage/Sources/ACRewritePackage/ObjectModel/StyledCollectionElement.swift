import Foundation

enum ContainerStyle: String, Codable {
    case none, defaultStyle = "default"
}

enum VerticalContentAlignment: String, Codable {
    case top, center, bottom
}

enum ContainerBleedDirection: String, Codable {
    case bleedAll, bleedRestricted
}

struct StyledCollectionElement: Codable {
    var style: ContainerStyle
    var verticalContentAlignment: VerticalContentAlignment?
    var bleedDirection: ContainerBleedDirection
    var minHeight: UInt
    var hasPadding: Bool
    var hasBleed: Bool
    var showBorder: Bool
    var roundedCorners: Bool
    var parentalId: UUID?
    var backgroundImage: BackgroundImage?
    var selectAction: BaseActionElement?

    init(type: String, 
         style: ContainerStyle = .none, 
         verticalContentAlignment: VerticalContentAlignment? = nil, 
         bleedDirection: ContainerBleedDirection = .bleedAll, 
         minHeight: UInt = 0, 
         hasPadding: Bool = false, 
         hasBleed: Bool = false, 
         showBorder: Bool = false, 
         roundedCorners: Bool = false, 
         parentalId: UUID? = nil, 
         backgroundImage: BackgroundImage? = nil, 
         selectAction: BaseActionElement? = nil) {
        
        self.style = style
        self.verticalContentAlignment = verticalContentAlignment
        self.bleedDirection = bleedDirection
        self.minHeight = minHeight
        self.hasPadding = hasPadding
        self.hasBleed = hasBleed
        self.showBorder = showBorder
        self.roundedCorners = roundedCorners
        self.parentalId = parentalId
        self.backgroundImage = backgroundImage
        self.selectAction = selectAction
    }

    func shouldSerialize() -> Bool {
        return true
    }

    mutating func configForContainerStyle(context: ParseContext) {
        configPadding(context: context)
        configBleed(context: context)
    }

    mutating func configPadding(context: ParseContext) {
        self.hasPadding = (self.style != .none && context.parentalContainerStyle != self.style)
    }

    mutating func configBleed(context: ParseContext) {
        if self.hasPadding && self.hasBleed && context.bleedDirection != .bleedRestricted {
            self.parentalId = context.paddingParentId
            self.bleedDirection = context.bleedDirection
        } else {
            self.bleedDirection = .bleedRestricted
        }
    }

    func serialize() throws -> String {
        let jsonData = try JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    func serializeToJsonValue() -> [String: Any] {
        var json: [String: Any] = [:]

        if let selectAction = selectAction {
            json["selectAction"] = selectAction.serializeToJsonValue()
        }

        if let backgroundImage = backgroundImage, !backgroundImage.url.isEmpty {
            json["backgroundImage"] = backgroundImage.serializeToJsonValue()
        }

        if style != .none {
            json["style"] = style.rawValue
        }

        if let verticalAlignment = verticalContentAlignment {
            json["verticalContentAlignment"] = verticalAlignment.rawValue
        }

        if hasBleed {
            json["bleed"] = true
        }

        if minHeight > 0 {
            json["minHeight"] = "\(minHeight)px"
        }

        return json
    }

    static func deserialize(from json: Data) throws -> StyledCollectionElement {
        return try JSONDecoder().decode(StyledCollectionElement.self, from: json)
    }

    static func deserializeFromString(_ jsonString: String) throws -> StyledCollectionElement {
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "Invalid JSON string", code: -1, userInfo: nil)
        }
        return try deserialize(from: data)
    }
}
