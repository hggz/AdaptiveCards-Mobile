import Foundation

/// Represents an input element in an Adaptive Card. This class inherits from BaseCardElement and adds additional
/// properties specific to input elements.
class SwiftBaseInputElement: SwiftBaseCardElement {
    // MARK: - Properties
    /// The text label for the input element.
    let label: String?
    /// Indicates whether a value is required.
    let isRequired: Bool
    /// The error message to display if the input is invalid.
    let errorMessage: String?
    /// An action to execute when the input's value changes.
    let valueChangedAction: SwiftValueChangedAction?

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case label
        case isRequired
        case errorMessage
        case valueChangedAction
    }
    
    /// Designated initializer.
    /// - Parameters:
    ///   - type: The type of card element (inherited from BaseCardElement).
    ///   - id: An optional identifier.
    ///   - label: Optional label text.
    ///   - isRequired: Whether the input is required (default is `false`).
    ///   - errorMessage: Optional error message.
    ///   - valueChangedAction: Optional action for value change events.
    ///   - spacing: Optional spacing setting.
    ///   - height: Optional height type.
    ///   - targetWidth: Optional target width type.
    ///   - separator: Optional flag indicating whether a separator should be shown.
    ///   - isVisible: Visibility flag (default is `true`).
    ///   - areaGridName: Optional grid name.
    init(
        type: SwiftCardElementType,
        id: String? = nil,
        label: String? = nil,
        isRequired: Bool = false,
        errorMessage: String? = nil,
        valueChangedAction: SwiftValueChangedAction? = nil,
        spacing: SwiftSpacing? = nil,
        height: SwiftHeightType? = nil,
        targetWidth: SwiftTargetWidthType? = nil,
        separator: Bool? = nil,
        isVisible: Bool = true,
        areaGridName: String? = nil
    ) {
        self.label = label
        self.isRequired = isRequired
        self.errorMessage = errorMessage
        self.valueChangedAction = valueChangedAction
        super.init(
            type: type,
            spacing: spacing,
            height: height,
            targetWidth: targetWidth,
            separator: separator,
            isVisible: isVisible,
            areaGridName: areaGridName,
            id: id
        )
    }

    /// Decodes properties from the given decoder.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        label = try container.decodeIfPresent(String.self, forKey: .label)
        isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired) ?? false
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        valueChangedAction = try container.decodeIfPresent(SwiftValueChangedAction.self, forKey: .valueChangedAction)
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }

    /// Encodes properties into the given encoder.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encodeIfPresent(errorMessage, forKey: .errorMessage)
        try container.encodeIfPresent(valueChangedAction, forKey: .valueChangedAction)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    /// Serializes the BaseInputElement to a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
}
