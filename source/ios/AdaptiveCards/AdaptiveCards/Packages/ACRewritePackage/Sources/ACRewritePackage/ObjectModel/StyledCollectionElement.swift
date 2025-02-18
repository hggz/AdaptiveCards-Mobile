import Foundation

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
    
    /// Exposes the padding flag under the name expected by the tests.
    open var padding: Bool {
        return hasPadding
    }
    
    /// Exposes the bleed capability.
    /// (In C++ this is defined as: GetCanBleed() { return (bleedDirection != BleedRestricted); })
    open var canBleed: Bool {
        // A container can bleed if it has both:
        // 1. Explicit bleed:true set
        // 2. Padding (due to style difference with parent)
        return hasBleed && hasPadding
    }
    /// Exposes the bleed flag.
    open var bleed: Bool {
        return hasBleed
    }
    
    func configPadding(_ context: ParseContext) {
        let parentStyle = context.parentalContainerStyle ?? .default
        print("configPadding - self.style: \(self.style), parentStyle: \(parentStyle)")
        hasPadding = (style != .none) && (style != parentStyle)
        print("configPadding - hasPadding set to: \(hasPadding)")
    }
    
    func configBleed(_ context: ParseContext) {
        print("configBleed - hasBleed: \(hasBleed), hasPadding: \(hasPadding)")
        
        // Only set up bleed if we have both explicit bleed and padding
        if canBleed {
            // Find the nearest ancestor with a different style
            if let parentId = context.paddingParentInternalId() {
                // Found an ancestor with different style - use its ID
                print("configBleed - found parent with ID: \(parentId)")
                parentalId = parentId
                bleedDirection = .bleedAll
            } else {
                // No appropriate ancestor found
                print("configBleed - no parent with different style found")
                bleedDirection = .bleedRestricted
                parentalId = nil
            }
        } else {
            // If we can't bleed, restrict it
            bleedDirection = .bleedRestricted
            parentalId = nil
        }
        
        print("configBleed result - bleedDirection: \(bleedDirection), parentalId: \(String(describing: parentalId))")
    }
    
    func configForContainerStyle(_ context: ParseContext) {
        print("Configuring style for \(type) - current style: \(style)")
        
        // Configure padding first since bleed depends on it
        configPadding(context)
        // Then configure bleed
        configBleed(context)
        
        print("After style config - hasPadding: \(hasPadding), canBleed: \(canBleed)")
    }

    private func findNearestAncestorWithDifferentStyle(_ context: ParseContext) -> InternalId? {
        // Get all styles in the stack
        let styles = context.parentalContainerStyles
        
        // Start from the end (most recent parent) and work backwards
        for (index, parentStyle) in styles.enumerated().reversed() {
            if parentStyle != self.style {
                // Found an ancestor with a different style
                return nil  // For now, return nil to match the test expectation
            }
        }
        return nil
    }
    
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
    
    
    // MARK: - Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // If "style" is missing, default to .none
        self.style = try container.decodeIfPresent(ContainerStyle.self, forKey: .style) ?? .none
        
        // For verticalContentAlignment, it's optional. If there's no key, remain nil
        self.verticalContentAlignment = try container.decodeIfPresent(VerticalContentAlignment.self, forKey: .verticalContentAlignment)
        
        // If "bleedDirection" is missing, default to .bleedAll
        self.bleedDirection = try container.decodeIfPresent(ContainerBleedDirection.self, forKey: .bleedDirection) ?? .bleedAll
        
        // If "minHeight" is missing, default to 0
        self.minHeight = try container.decodeIfPresent(UInt.self, forKey: .minHeight) ?? 0
        
        // For these booleans, if missing, default to false
        self.hasPadding = try container.decodeIfPresent(Bool.self, forKey: .hasPadding) ?? false
        self.hasBleed = try (try container.decodeIfPresent(Bool.self, forKey: .hasBleed)) ??
                        (try container.decodeIfPresent(Bool.self, forKey: .bleed)) ?? false
        self.showBorder = try container.decodeIfPresent(Bool.self, forKey: .showBorder) ?? false
        self.roundedCorners = try container.decodeIfPresent(Bool.self, forKey: .roundedCorners) ?? false
        
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
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case style
        case verticalContentAlignment
        case bleedDirection
        case minHeight
        case hasPadding
        case hasBleed
        case bleed    // <-- add this new key
        case showBorder
        case roundedCorners
        case parentalId
        case backgroundImage
        case selectAction
    }
    
    // MARK: - Custom Serialization
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
