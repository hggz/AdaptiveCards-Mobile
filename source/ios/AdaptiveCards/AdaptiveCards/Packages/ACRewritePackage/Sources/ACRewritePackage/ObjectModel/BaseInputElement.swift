import Foundation

/// Represents an input element in an Adaptive Card. This class inherits from BaseCardElement and adds additional
/// properties specific to input elements.
class BaseInputElement: BaseCardElement {
    // MARK: - Properties
    /// The text label for the input element.
    var label: String?
    /// Indicates whether a value is required.
    var isRequired: Bool
    /// The error message to display if the input is invalid.
    var errorMessage: String?
    /// An action to execute when the input’s value changes.
    var valueChangedAction: ValueChangedAction?

    // MARK: - Initializers

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
        type: CardElementType,
        id: String? = nil,
        label: String? = nil,
        isRequired: Bool = false,
        errorMessage: String? = nil,
        valueChangedAction: ValueChangedAction? = nil,
        spacing: Spacing? = nil,
        height: HeightType? = nil,
        targetWidth: TargetWidthType? = nil,
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

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case label
        case isRequired
        case errorMessage
        case valueChangedAction
    }

    /// Decodes properties from the given decoder.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired) ?? false
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.valueChangedAction = try container.decodeIfPresent(ValueChangedAction.self, forKey: .valueChangedAction)
        try super.init(from: decoder)
    }

    /// Encodes properties into the given encoder.
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encodeIfPresent(errorMessage, forKey: .errorMessage)
        try container.encodeIfPresent(valueChangedAction, forKey: .valueChangedAction)
    }

    // MARK: - Serialization Helpers

    /// Serializes the BaseInputElement to a JSON string.
    /// - Returns: A JSON string representation.
    /// - Throws: An error if the encoding fails.
    func serialize() throws -> String {
        let jsonData = try JSONEncoder().encode(self)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw SerializationError.invalidData
        }
        return jsonString
    }

    /// Determines whether this element has sufficient data to be serialized.
    /// Checks if at least one of the key properties is non-empty.
    func shouldSerialize() -> Bool {
        // Assuming `id` is a property inherited from BaseElement (via BaseCardElement).
        let idNotEmpty = (super.id ?? "").isEmpty == false
        let labelNotEmpty = !(label?.isEmpty ?? true)
        let errorMessageNotEmpty = !(errorMessage?.isEmpty ?? true)
        return idNotEmpty || isRequired || labelNotEmpty || errorMessageNotEmpty
    }
}
