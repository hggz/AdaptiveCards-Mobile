import Foundation

/// Errors that can occur during serialization or deserialization.
enum SerializationError: Error {
    case stringEncodingFailed
    case stringDecodingFailed
    case invalidJsonString
    case invalidData
}

// MARK: - TableColumnDefinition

/// A Swift port of the C++ TableColumnDefinition.
/// This structure is Codable, uses value semantics, and enforces that
/// setting a relative width resets an explicit pixel width and vice versa.
struct TableColumnDefinition: Codable {
    
    // MARK: Properties
    
    /// Optional horizontal alignment for cell content.
    /// Defaults to `.left` in the default initializer.
    var horizontalCellContentAlignment: HorizontalAlignment? = .left
    
    /// Optional vertical alignment for cell content.
    /// Defaults to `.top` in the default initializer.
    var verticalCellContentAlignment: VerticalContentAlignment? = .top
    
    /// The relative width (e.g. “2”) of the column.
    /// Setting this will reset `pixelWidth`.
    var width: UInt? {
        didSet {
            if width != nil {
                pixelWidth = nil
            }
        }
    }
    
    /// The explicit pixel width (e.g. “100px”) of the column.
    /// Setting this will reset `width`.
    var pixelWidth: UInt? {
        didSet {
            if pixelWidth != nil {
                width = nil
            }
        }
    }
    
    // MARK: Initializers
    
    /// Default initializer that sets default alignments.
    init() {
        self.horizontalCellContentAlignment = .left
        self.verticalCellContentAlignment = .top
        self.width = nil
        self.pixelWidth = nil
    }
    
    /// Custom initializer for decoding.
    /// Handles the "width" field, which can be either an unsigned integer or a string with a "px" suffix.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let horizontalString = try container.decodeIfPresent(String.self, forKey: .horizontalCellContentAlignment) {
            self.horizontalCellContentAlignment = HorizontalAlignment(rawValue: horizontalString.lowercased()) ?? .left
        } else {
            self.horizontalCellContentAlignment = .left
        }
        
        if let verticalString = try container.decodeIfPresent(String.self, forKey: .verticalCellContentAlignment) {
            self.verticalCellContentAlignment = VerticalContentAlignment(from: verticalString)
        } else {
            self.verticalCellContentAlignment = .top
        }
        // Decode the "width" field.
        if container.contains(.width) {
            if let intValue = try? container.decode(UInt.self, forKey: .width) {
                self.width = intValue
                self.pixelWidth = nil
            } else if let stringValue = try? container.decode(String.self, forKey: .width) {
                if stringValue.hasSuffix("px") {
                    let numberPart = stringValue.dropLast(2)
                    if let pixelValue = UInt(numberPart) {
                        self.pixelWidth = pixelValue
                        self.width = nil
                    } else {
                        self.width = nil
                        self.pixelWidth = nil
                    }
                } else {
                    // When the unit is missing, do not set either width or pixelWidth.
                    self.width = nil
                    self.pixelWidth = nil
                }
            } else {
                throw DecodingError.dataCorruptedError(forKey: .width,
                                                       in: container,
                                                       debugDescription: "Invalid type for width")
            }
        } else {
            self.width = nil
            self.pixelWidth = nil
        }
    }
    
    /// Custom encoding to handle the "width" field.
    /// If `pixelWidth` is set, it takes precedence over `width` and is encoded as a string with a "px" suffix.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let horizontal = horizontalCellContentAlignment {
            try container.encode(horizontal.rawValue, forKey: .horizontalCellContentAlignment)
        }
        if let vertical = verticalCellContentAlignment {
            try container.encode(vertical.rawValue, forKey: .verticalCellContentAlignment)
        }
        if let pixelWidth = pixelWidth {
            try container.encode("\(pixelWidth)px", forKey: .width)
        } else if let width = width {
            try container.encode(width, forKey: .width)
        }
    }
    
    // MARK: Serialization Methods
    
    /// Serializes the current instance into a JSON string.
    /// - Returns: A JSON string representing the instance.
    /// - Throws: An error if encoding fails.
    func serialize() throws -> String {
        let encoder = JSONEncoder()
        // Remove prettyPrinting to get compact JSON
        let data = try encoder.encode(self)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw SerializationError.stringEncodingFailed
        }
        // Add newline to match expected format
        return jsonString + "\n"
    }
    
    /// Deserializes an instance of `TableColumnDefinition` from JSON data.
    /// - Parameter data: The JSON data.
    /// - Returns: A new instance of `TableColumnDefinition`.
    /// - Throws: An error if decoding fails.
    static func deserialize(from data: Data) throws -> TableColumnDefinition {
        let decoder = JSONDecoder()
        return try decoder.decode(TableColumnDefinition.self, from: data)
    }
    
    /// Deserializes an instance of `TableColumnDefinition` from a JSON string.
    /// - Parameter jsonString: The JSON string.
    /// - Returns: A new instance of `TableColumnDefinition`.
    /// - Throws: An error if the string cannot be converted to data or decoding fails.
    static func deserialize(from jsonString: String) throws -> TableColumnDefinition {
        guard let data = jsonString.data(using: .utf8) else {
            throw SerializationError.stringDecodingFailed
        }
        return try deserialize(from: data)
    }
    
    // MARK: - Coding Keys
    
    /// Maps the property names to JSON keys.
    enum CodingKeys: String, CodingKey {
        case horizontalCellContentAlignment = "horizontalCellContentAlignment"
        case verticalCellContentAlignment = "verticalCellContentAlignment"
        case width = "width"
    }
    
    static func deserialize(context: ParseContext, from json: [String: Any]) throws -> TableColumnDefinition {
        if let widthValue = json["width"] as? String, !widthValue.hasSuffix("px") {
            context.warnings.append(.init(statusCode: .noRendererForType, message: "Width string with no unit in TableColumnDefinition: \(widthValue)"))
        }
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(TableColumnDefinition.self, from: data)
    }
    
    func serializeToJsonValue() throws -> [String: Any] {
        var json: [String: Any] = [:]
        // Only include width or pixelWidth, not both
        if let pixelWidth = pixelWidth {
            json["width"] = "\(pixelWidth)px"
        } else if let width = width {
            json["width"] = width
        }
        return json
    }
}

extension TableColumnDefinition {
    static func deserialize(context: ParseContext, from jsonString: String) throws -> TableColumnDefinition {
        let dict = try ParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(context: context, from: dict)
    }
}
