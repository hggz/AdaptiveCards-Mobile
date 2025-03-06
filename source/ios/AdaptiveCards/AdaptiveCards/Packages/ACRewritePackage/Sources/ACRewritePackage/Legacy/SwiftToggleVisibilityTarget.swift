import Foundation

/// Enum representing visibility states for an element in Adaptive Cards.
enum SwiftIsVisible: String, Codable {
    case toggle = "toggle"
    case visible = "true"
    case hidden = "false"
}

/// Represents a target element for the `ToggleVisibilityAction`.
struct SwiftToggleVisibilityTarget: Codable {
    /// The ID of the target element whose visibility will be toggled.
    let elementId: String
    /// The visibility state of the target element.
    let isVisible: SwiftIsVisible
}
