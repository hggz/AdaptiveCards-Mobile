import Foundation

/// Represents the context during parsing of an Adaptive Card, tracking hierarchy and element state.
struct ParseContext {
    var elementParserRegistration: ElementParserRegistration?
    var actionParserRegistration: ActionParserRegistration?
    var warnings: [AdaptiveCardParseWarning] = []
    
    /// Keeps track of seen elements to detect ID collisions.
    private var elementIds: [String: InternalId] = [:]
    
    /// Stack used during parsing to track the hierarchy of elements.
    private var idStack: [(id: String, internalId: InternalId, isFallback: Bool)] = []
    
    /// Tracks container styles as they are nested.
    private var parentalContainerStyles: [ContainerStyle] = []
    
    /// Tracks padding elements in the parse hierarchy.
    private var parentalPadding: [InternalId] = []
    
    /// Tracks bleed direction during parsing.
    private var parentalBleedDirection: [ContainerBleedDirection] = []
    
    /// Determines if fallback to an ancestor element is possible.
    var canFallbackToAncestor: Bool = false
    
    /// The language setting for parsing.
    var language: String?

    // MARK: - Initializers
    
    init() {}

    init(elementParserRegistration: ElementParserRegistration?, actionParserRegistration: ActionParserRegistration?) {
        self.elementParserRegistration = elementParserRegistration
        self.actionParserRegistration = actionParserRegistration
    }
    
    // MARK: - Hierarchy Management
    
    /// Push an element onto the parsing stack.
    mutating func pushElement(idJsonProperty: String, internalId: InternalId, isFallback: Bool = false) {
        idStack.append((id: idJsonProperty, internalId: internalId, isFallback: isFallback))
    }
    
    /// Pop the last element off the parsing stack.
    mutating func popElement() {
        _ = idStack.popLast()
    }
    
    /// Retrieve the nearest valid fallback ID in the hierarchy.
    func getNearestFallbackId(skipId: InternalId) -> InternalId? {
        return idStack.reversed().first { $0.internalId != skipId }?.internalId
    }
    
    // MARK: - Style and Context Management
    
    mutating func setLanguage(_ value: String) {
        language = value
    }
    
    func getLanguage() -> String? {
        return language
    }
    
    mutating func setParentalContainerStyle(_ style: ContainerStyle) {
        parentalContainerStyles.append(style)
    }
    
    func getParentalContainerStyle() -> ContainerStyle? {
        return parentalContainerStyles.last
    }
    
    func paddingParentInternalId() -> InternalId? {
        return parentalPadding.last
    }
    
    mutating func saveContextForStyledCollectionElement(_ current: StyledCollectionElement) {
        parentalPadding.append(InternalId.next())
    }
    
    mutating func restoreContextForStyledCollectionElement(_ current: StyledCollectionElement) {
        _ = parentalPadding.popLast()
    }
    
    mutating func pushBleedDirection(_ direction: ContainerBleedDirection) {
        parentalBleedDirection.append(direction)
    }
    
    mutating func popBleedDirection() {
        _ = parentalBleedDirection.popLast()
    }
}
