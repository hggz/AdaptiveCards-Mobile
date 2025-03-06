import Foundation

// MARK: - Consolidated SwiftSeparator Legacy Support

/// Unified legacy support for SwiftSeparator parsing and serialization
enum SwiftSeparatorLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftSeparator
    static func deserialize(from value: [String: Any]) throws -> SwiftSeparator {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftSeparator.self, from: data)
    }
    
    /// Deserializes string into a SwiftSeparator
    static func deserialize(from jsonString: String) throws -> SwiftSeparator {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftSeparator.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftSeparator to JSON dictionary with proper formatting
    static func serializeToJson(_ separator: SwiftSeparator) -> [String: Any] {
        var json: [String: Any] = [:]
        
        // Add properties
        json[SwiftAdaptiveCardSchemaKey.color.rawValue] = separator.color.rawValue
        json[SwiftAdaptiveCardSchemaKey.thickness.rawValue] = separator.thickness.rawValue
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ separator: SwiftSeparator) throws -> String {
        let json = serializeToJson(separator)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - SwiftSeparator Extension

extension SwiftSeparator {
    // Legacy static factory methods
    
    /// Decodes a `Separator` from a JSON dictionary.
    static func deserialize(from json: [String: Any]) throws -> SwiftSeparator {
        return try SwiftSeparatorLegacySupport.deserialize(from: json)
    }
    
    /// Decodes a `Separator` from a JSON string.
    static func deserialize(from jsonString: String) throws -> SwiftSeparator {
        return try SwiftSeparatorLegacySupport.deserialize(from: jsonString)
    }
    
    /// Encodes `Separator` to a JSON string.
    func serialize() throws -> String {
        return try SwiftSeparatorLegacySupport.serializeToJsonString(self)
    }
}

// MARK: - Consolidated SwiftTable Legacy Support

/// Unified legacy support for SwiftTable parsing and serialization
enum SwiftTableLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTable
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftTable {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftTable.self, from: data)
    }
    
    /// Deserializes string into a SwiftTable
    static func deserialize(from jsonString: String) throws -> SwiftTable {
        guard let data = jsonString.data(using: .utf8) else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try JSONDecoder().decode(SwiftTable.self, from: data)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTable to JSON dictionary with proper formatting
    static func serializeToJson(_ table: SwiftTable, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Only include non-empty arrays
        if !table.columnDefinitions.isEmpty {
            json["columns"] = try table.columnDefinitions.map { try $0.serializeToJsonValue() }
        }
        
        if !table.rows.isEmpty {
            json["rows"] = try table.rows.map { try $0.serializeToJsonValue() }
        }
        
        // Only add properties that differ from defaults
        if table.showGridLines != true {
            json["showGridLines"] = table.showGridLines
        }
        
        if table.roundedCorners {
            json["roundedCorners"] = table.roundedCorners
        }
        
        if let horizontalAlignment = table.horizontalCellContentAlignment {
            json["horizontalCellContentAlignment"] = horizontalAlignment.rawValue
        }
        
        if let verticalAlignment = table.verticalCellContentAlignment {
            json["verticalCellContentAlignment"] = verticalAlignment.rawValue
        }
        
        if table.gridStyle != .none {
            json["gridStyle"] = SwiftContainerStyle.toString(table.gridStyle)  // Use toString
        }
        
        if !table.firstRowAsHeaders {
            json["firstRowAsHeaders"] = table.firstRowAsHeaders
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses Table elements in an Adaptive Card.
struct SwiftTableParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        // Verify that the type is correct, using case-insensitive comparison
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.table)
        
        // Use the global BaseCardElement deserialization and cast to Table.
        guard let table = try SwiftBaseCardElement.deserialize(from: value) as? SwiftTable else {
            print("Failed to cast deserialized element to Table")
            throw AdaptiveCardParseError.invalidType
        }
        return table
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        guard let table = try SwiftBaseCardElement.deserialize(from: value) as? SwiftTable else {
            throw AdaptiveCardParseError.invalidType
        }
        return table
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}

extension SwiftTableParser {
    func deserialize(from value: String, context: SwiftParseContext) throws -> any SwiftAdaptiveCardElementProtocol {
        return try self.deserialize(fromString: context, value: value)
    }
}

// MARK: - SwiftTable Extension

internal extension SwiftTable {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        // Clear any additional properties first
        self.additionalProperties = nil
        return try SwiftTableLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Known Properties
    func populateKnownPropertiesSet() {
        self.knownProperties = Set([
            "type",
            "id",
            "columns",
            "rows",
            "showGridLines",
            "roundedCorners",
            "horizontalCellContentAlignment",
            "verticalCellContentAlignment",
            "gridStyle",
            "firstRowAsHeaders"
        ])
    }
}

// MARK: - Consolidated SwiftTableCell Legacy Support

/// Unified legacy support for SwiftTableCell parsing and serialization
enum SwiftTableCellLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTableCell
    static func deserialize(from value: [String: Any], context: SwiftParseContext) throws -> SwiftTableCell {
        let idProperty = value[SwiftAdaptiveCardSchemaKey.id.rawValue] as? String ?? ""
        let internalId = SwiftInternalId.next()
        
        context.pushElement(idJsonProperty: idProperty, internalId: internalId)
        
        // Convert the JSON dictionary to Data.
        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
        let cell = try JSONDecoder().decode(SwiftTableCell.self, from: jsonData)
        
        // Explicitly set style if provided
        if let styleString = value["style"] as? String {
            cell.style = SwiftContainerStyle(rawValue: styleString.capitalized) ?? .none
        }
        
        // Set RTL if present
        if let rtl = value[SwiftAdaptiveCardSchemaKey.rtl.rawValue] as? Bool {
            cell.setRtl(rtl)
        }
        
        cell.additionalProperties = nil
        context.popElement()
        return cell
    }
    
    /// Deserializes string into a SwiftTableCell
    static func deserialize(from jsonString: String, context: SwiftParseContext) throws -> SwiftTableCell {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict, context: context)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTableCell to JSON dictionary with proper formatting
    static func serializeToJson(_ cell: SwiftTableCell, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Add items if present
        if !cell.items.isEmpty {
            json["items"] = try cell.items.map { try $0.serializeToJsonValue() }
        }
        
        // Add rtl if present
        if let rtl = cell.rtl {
            json["rtl"] = rtl
        }
        
        // Add style with proper capitalization if not .none
        if cell.style != .none {
            json["style"] = cell.style.rawValue  // Use rawValue to get capitalized version
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses TableCell elements in an Adaptive Card.
struct SwiftTableCellParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.tableCell)
        return try SwiftTableCellLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTableCellLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTableCellLegacySupport.deserialize(from: value, context: context)
    }
}

// MARK: - SwiftTableCell Extension

internal extension SwiftTableCell {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftTableCellLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Static Factory Methods
    
    /// Deserializes a `TableCell` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: SwiftParseContext) throws -> SwiftTableCell {
        return try SwiftTableCellLegacySupport.deserialize(from: json, context: context)
    }
    
    /// Deserializes a `TableCell` from a JSON string.
    static func deserialize(from jsonString: String, context: SwiftParseContext) throws -> SwiftTableCell {
        return try SwiftTableCellLegacySupport.deserialize(from: jsonString, context: context)
    }
}

/// Errors that can occur during serialization or deserialization.
enum SerializationError: Error {
    case stringEncodingFailed
    case stringDecodingFailed
    case invalidJsonString
    case invalidData
}

// MARK: - Consolidated SwiftTableColumnDefinition Legacy Support

/// Unified legacy support for SwiftTableColumnDefinition parsing and serialization
enum SwiftTableColumnDefinitionLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTableColumnDefinition
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> SwiftTableColumnDefinition {
        // Check for potential warnings
        if let context = context,
           let widthValue = value["width"] as? String,
           !widthValue.hasSuffix("px") {
            context.warnings.append(.init(
                statusCode: .noRendererForType,
                message: "Width string with no unit in TableColumnDefinition: \(widthValue)")
            )
        }
        
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftTableColumnDefinition.self, from: data)
    }
    
    /// Deserializes Data into a SwiftTableColumnDefinition
    static func deserialize(from data: Data) throws -> SwiftTableColumnDefinition {
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftTableColumnDefinition.self, from: data)
    }
    
    /// Deserializes string into a SwiftTableColumnDefinition
    static func deserialize(from jsonString: String) throws -> SwiftTableColumnDefinition {
        guard let data = jsonString.data(using: .utf8) else {
            throw SerializationError.stringDecodingFailed
        }
        return try deserialize(from: data)
    }
    
    /// Deserializes string into a SwiftTableColumnDefinition with context
    static func deserialize(from jsonString: String, context: SwiftParseContext) throws -> SwiftTableColumnDefinition {
        let dict = try SwiftParseUtil.getJsonDictionary(from: jsonString)
        return try deserialize(from: dict, context: context)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTableColumnDefinition to JSON dictionary with proper formatting
    static func serializeToJson(_ columnDefinition: SwiftTableColumnDefinition) throws -> [String: Any] {
        var json: [String: Any] = [:]
        
        // Only include alignment values if they differ from defaults
        if let horizontal = columnDefinition.horizontalCellContentAlignment, horizontal != .left {
            json["horizontalCellContentAlignment"] = horizontal.rawValue
        }
        
        if let vertical = columnDefinition.verticalCellContentAlignment, vertical != .top {
            json["verticalCellContentAlignment"] = vertical.rawValue
        }
        
        // Only include width or pixelWidth, not both (prioritize pixelWidth)
        if let pixelWidth = columnDefinition.pixelWidth {
            json["width"] = "\(pixelWidth)px"
        } else if let width = columnDefinition.width {
            json["width"] = width
        }
        
        return json
    }
    
    /// Serializes to JSON string
    static func serializeToJsonString(_ columnDefinition: SwiftTableColumnDefinition) throws -> String {
        let encoder = JSONEncoder()
        // Remove prettyPrinting to get compact JSON
        let data = try encoder.encode(columnDefinition)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw SerializationError.stringEncodingFailed
        }
        // Add newline to match expected format
        return jsonString + "\n"
    }
}

// MARK: - SwiftTableColumnDefinition Extension

extension SwiftTableColumnDefinition {
    // Legacy serialization methods
    
    /// Serializes the current instance into a JSON string.
    /// - Returns: A JSON string representing the instance.
    /// - Throws: An error if encoding fails.
    func serialize() throws -> String {
        return try SwiftTableColumnDefinitionLegacySupport.serializeToJsonString(self)
    }
    
    // Legacy static factory methods
    
    /// Deserializes an instance of `TableColumnDefinition` from JSON data.
    /// - Parameter data: The JSON data.
    /// - Returns: A new instance of `TableColumnDefinition`.
    /// - Throws: An error if decoding fails.
    static func deserialize(from data: Data) throws -> SwiftTableColumnDefinition {
        return try SwiftTableColumnDefinitionLegacySupport.deserialize(from: data)
    }
    
    /// Deserializes an instance of `TableColumnDefinition` from a JSON string.
    /// - Parameter jsonString: The JSON string.
    /// - Returns: A new instance of `TableColumnDefinition`.
    /// - Throws: An error if the string cannot be converted to data or decoding fails.
    static func deserialize(from jsonString: String) throws -> SwiftTableColumnDefinition {
        return try SwiftTableColumnDefinitionLegacySupport.deserialize(from: jsonString)
    }
    
    /// Deserializes from a JSON dictionary with context
    static func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> SwiftTableColumnDefinition {
        return try SwiftTableColumnDefinitionLegacySupport.deserialize(from: json, context: context)
    }
    
    /// Deserializes from a JSON string with context
    static func deserialize(context: SwiftParseContext, from jsonString: String) throws -> SwiftTableColumnDefinition {
        return try SwiftTableColumnDefinitionLegacySupport.deserialize(from: jsonString, context: context)
    }
}
