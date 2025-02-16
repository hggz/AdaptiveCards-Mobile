import Foundation

/// Enumeration for bleed directions.
enum ContainerBleedDirection: String, Codable {
    case bleedAll, bleedRestricted
}

/// The styled collection element base class (made inheritable).
class StyledCollectionElement: BaseCardElement {
    var style: ContainerStyle
    var verticalContentAlignment: VerticalContentAlignment?
    var bleedDirection: ContainerBleedDirection
    var minHeight: UInt
    var hasPadding: Bool
    var hasBleed: Bool
    var showBorder: Bool
    var roundedCorners: Bool
    var parentalId: InternalId?
    var backgroundImage: BackgroundImage?
    var selectAction: BaseActionElement?
    
    init(type: CardElementType,
         style: ContainerStyle = .none,
         verticalContentAlignment: VerticalContentAlignment? = nil,
         bleedDirection: ContainerBleedDirection = .bleedAll,
         minHeight: UInt = 0,
         hasPadding: Bool = false,
         hasBleed: Bool = false,
         showBorder: Bool = false,
         roundedCorners: Bool = false,
         parentalId: InternalId? = nil,
         backgroundImage: BackgroundImage? = nil,
         selectAction: BaseActionElement? = nil,
         id: String? = nil) {
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
        super.init(type: type, id: id)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.style = try container.decode(ContainerStyle.self, forKey: .style)
        self.verticalContentAlignment = try container.decodeIfPresent(VerticalContentAlignment.self, forKey: .verticalContentAlignment)
        self.bleedDirection = try container.decode(ContainerBleedDirection.self, forKey: .bleedDirection)
        self.minHeight = try container.decode(UInt.self, forKey: .minHeight)
        self.hasPadding = try container.decode(Bool.self, forKey: .hasPadding)
        self.hasBleed = try container.decode(Bool.self, forKey: .hasBleed)
        self.showBorder = try container.decode(Bool.self, forKey: .showBorder)
        self.roundedCorners = try container.decode(Bool.self, forKey: .roundedCorners)
        self.parentalId = try container.decodeIfPresent(InternalId.self, forKey: .parentalId)
        self.backgroundImage = try container.decodeIfPresent(BackgroundImage.self, forKey: .backgroundImage)
        self.selectAction = try container.decodeIfPresent(BaseActionElement.self, forKey: .selectAction)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(style, forKey: .style)
        try container.encodeIfPresent(verticalContentAlignment, forKey: .verticalContentAlignment)
        try container.encode(bleedDirection, forKey: .bleedDirection)
        try container.encode(minHeight, forKey: .minHeight)
        try container.encode(hasPadding, forKey: .hasPadding)
        try container.encode(hasBleed, forKey: .hasBleed)
        try container.encode(showBorder, forKey: .showBorder)
        try container.encode(roundedCorners, forKey: .roundedCorners)
        try container.encodeIfPresent(parentalId, forKey: .parentalId)
        try container.encodeIfPresent(backgroundImage, forKey: .backgroundImage)
        try container.encodeIfPresent(selectAction, forKey: .selectAction)
        try super.encode(to: encoder)
    }
    
    enum CodingKeys: String, CodingKey {
        case style, verticalContentAlignment, bleedDirection, minHeight, hasPadding, hasBleed, showBorder, roundedCorners, parentalId, backgroundImage, selectAction
    }
    
    func serializeToJsonV() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        json["style"] = style.rawValue
        if let verticalAlignment = verticalContentAlignment {
            json["verticalContentAlignment"] = verticalAlignment.rawValue
        }
        if hasBleed {
            json["bleed"] = true
        }
        if minHeight > 0 {
            json["minHeight"] = "\(minHeight)px"
        }
        if let selectAction = selectAction {
            json["selectAction"] = selectAction.toJSON()
        }
        if let backgroundImage = backgroundImage {
            json["backgroundImage"] = backgroundImage.serializeToJsonValue()
        }
        return json
    }
}
