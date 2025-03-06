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

// MARK: - Consolidated SwiftTableRow Legacy Support

/// Unified legacy support for SwiftTableRow parsing and serialization
enum SwiftTableRowLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTableRow
    static func deserialize(from value: [String: Any], context: SwiftParseContext) throws -> SwiftTableRow {
        // Retrieve the id property using the expected key from AdaptiveCardSchemaKey.
        let idProperty = value[SwiftAdaptiveCardSchemaKey.id.rawValue] as? String ?? ""
        let internalId = SwiftInternalId.next()
        
        // Push element to context
        context.pushElement(idJsonProperty: idProperty, internalId: internalId)
        
        // Create a new row and populate its properties
        let tableRow = SwiftTableRow()
        
        // Parse horizontal alignment
        tableRow.horizontalCellContentAlignment = try SwiftParseUtil.getOptionalEnumValue(
            from: value,
            key: "horizontalCellContentAlignment",
            converter: SwiftHorizontalAlignment.fromString
        )
        
        // Parse vertical alignment
        tableRow.verticalCellContentAlignment = try SwiftParseUtil.getOptionalEnumValue(
            from: value,
            key: "verticalCellContentAlignment",
            converter: SwiftVerticalContentAlignment.fromString
        )
        
        // Parse style
        tableRow.style = try SwiftParseUtil.getEnumValue(
            from: value,
            key: "style",
            defaultValue: .none,
            converter: SwiftContainerStyle.fromString
        )
        
        // Parse cells
        tableRow.cells = try SwiftParseUtil.getElementCollectionOfSingleType(
            from: value,
            key: "cells",
            context: context,
            defaultValue: [],
            converter: { (context: SwiftParseContext, json: [String: Any]) throws -> SwiftTableCell in
                return try SwiftTableCell.deserialize(from: json, context: context)
            }
        )
        
        // Clean up and return
        tableRow.additionalProperties = nil
        context.popElement()
        
        return tableRow
    }
    
    /// Deserializes string into a SwiftTableRow
    static func deserialize(from jsonString: String, context: SwiftParseContext) throws -> SwiftTableRow {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw SwiftAdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(from: jsonDict, context: context)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTableRow to JSON dictionary with proper formatting
    static func serializeToJson(_ tableRow: SwiftTableRow, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Add cells if present
        if !tableRow.cells.isEmpty {
            json["cells"] = try tableRow.cells.map { try $0.serializeToJsonValue() }
        }
        
        // Add style if not default with proper capitalization
        if tableRow.style != .none {
            json["style"] = tableRow.style.rawValue  // Uses proper capitalization
        }
        
        // Add alignments if present
        if let horizontal = tableRow.horizontalCellContentAlignment {
            json["horizontalCellContentAlignment"] = horizontal.rawValue
        }
        if let vertical = tableRow.verticalCellContentAlignment {
            json["verticalCellContentAlignment"] = vertical.rawValue.capitalized
        }
        
        return json
    }
}

// MARK: - Parser Implementation

/// Parses TableRow elements in an Adaptive Card.
struct SwiftTableRowParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.tableRow)
        return try SwiftTableRowLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTableRowLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        return try SwiftTableRowLegacySupport.deserialize(from: value, context: context)
    }
}

// MARK: - SwiftTableRow Extension

internal extension SwiftTableRow {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try SwiftTableRowLegacySupport.serializeToJson(self, baseJson: superResult)
    }
    
    // MARK: - Static Factory Methods
    
    /// Deserializes a `TableRow` from a JSON dictionary.
    static func deserialize(from json: [String: Any], context: SwiftParseContext) throws -> SwiftTableRow {
        return try SwiftTableRowLegacySupport.deserialize(from: json, context: context)
    }
    
    /// Deserializes a `TableRow` from a JSON string.
    static func deserialize(from jsonString: String, context: SwiftParseContext) throws -> SwiftTableRow {
        return try SwiftTableRowLegacySupport.deserialize(from: jsonString, context: context)
    }
}

// MARK: - Consolidated TextBlock Legacy Support

/// Unified legacy support for TextBlock parsing and serialization
enum TextBlockLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a TextBlock
    static func deserialize(from value: [String: Any], context: SwiftParseContext? = nil) throws -> TextBlock {
        // Convert dictionary to JSON data
        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(TextBlock.self, from: data)
    }
    
    /// Deserializes string into a TextBlock
    static func deserialize(from jsonString: String) throws -> TextBlock {
        guard let data = jsonString.data(using: .utf8) else {
            throw SerializationError.stringDecodingFailed
        }
        
        // Convert to dictionary first
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        
        return try deserialize(from: jsonDict)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a TextBlock to JSON dictionary with proper formatting
    static func serializeToJson(_ textBlock: TextBlock, baseJson: [String: Any]) throws -> [String: Any] {
        var json = baseJson
        
        // Always set the type
        json["type"] = "TextBlock"
        json["text"] = textBlock.text
        
        // Only include id if it's non-nil and non-empty
        if let id = textBlock.id, !id.isEmpty {
            json["id"] = id
        } else {
            // Remove id from json if it was added by super class
            json.removeValue(forKey: "id")
        }
        
        // Only include style if it differs from default
        if let textStyle = textBlock.textStyle, textStyle != .defaultStyle {
            json[SwiftAdaptiveCardSchemaKey.style.rawValue] = textStyle.rawValue
        }
        
        // Only include language if it's not "en"
        if let language = textBlock.language, language != "en" {
            json["lang"] = language
        }
        
        // Include other properties only if they have non-default values
        if let textSize = textBlock.textSize {
            json[SwiftAdaptiveCardSchemaKey.size.rawValue] = textSize.rawValue
        }
        
        if let textWeight = textBlock.textWeight {
            json[SwiftAdaptiveCardSchemaKey.weight.rawValue] = textWeight.rawValue
        }
        
        if let fontType = textBlock.fontType {
            json[SwiftAdaptiveCardSchemaKey.fontType.rawValue] = fontType.rawValue
        }
        
        if let textColor = textBlock.textColor {
            json[SwiftAdaptiveCardSchemaKey.color.rawValue] = textColor.serializedString
        }
        
        if let isSubtle = textBlock.isSubtle {
            json[SwiftAdaptiveCardSchemaKey.isSubtle.rawValue] = isSubtle
        }
        
        if textBlock.wrap {
            json[SwiftAdaptiveCardSchemaKey.wrap.rawValue] = textBlock.wrap
        }
        
        if textBlock.maxLines > 0 {
            json[SwiftAdaptiveCardSchemaKey.maxLines.rawValue] = textBlock.maxLines
        }
        
        if let horizontalAlignment = textBlock.horizontalAlignment {
            json[SwiftAdaptiveCardSchemaKey.horizontalAlignment.rawValue] = horizontalAlignment.rawValue
        }
        
        return json
    }
    
    /// Serializes to JSON string
    static func serializeToJsonString(_ textBlock: TextBlock) throws -> String {
        let json = try textBlock.serializeToJsonValue()
        let data = try JSONSerialization.data(withJSONObject: json, options: [.sortedKeys])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw AdaptiveCardParseError.serializationFailed
        }
        return jsonString + "\n"
    }
}

// MARK: - Parser Implementation

/// Parses TextBlock elements in an Adaptive Card.
struct SwiftTextBlockParser: SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        // Verify the type
        try SwiftParseUtil.expectTypeString(value, expected: SwiftCardElementType.textBlock)
        return try TextBlockLegacySupport.deserialize(from: value, context: context)
    }
    
    func deserializeWithoutCheckingType(context: SwiftParseContext, value: [String: Any]) throws -> any SwiftAdaptiveCardElementProtocol {
        return try TextBlockLegacySupport.deserialize(from: value)
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> any SwiftAdaptiveCardElementProtocol {
        let jsonDict = try SwiftParseUtil.getJsonDictionary(from: value)
        return try deserialize(context: context, value: jsonDict)
    }
}

// MARK: - TextBlock Extensions

extension TextBlock {
    /// Serializes to legacy JSON format
    func serializeToLegacyJsonFormat(superResult: [String: Any]) throws -> [String: Any] {
        return try TextBlockLegacySupport.serializeToJson(self, baseJson: superResult)
    }

    // MARK: - Helper Methods for HTML Entity Decoding
    
    /// Decodes HTML entities in the provided string using a single pass.
    /// Supported entities: &amp;, &lt;, &gt;, &nbsp;
    static func decodeHTMLEntities(_ input: String) -> String {
        let pattern = "&([a-zA-Z]+);"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return input }
        let nsInput = input as NSString
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: nsInput.length))
        
        var result = ""
        var lastRangeEnd = 0
        
        for match in matches {
            let matchRange = match.range
            // Append text between last match and current match.
            result.append(nsInput.substring(with: NSRange(location: lastRangeEnd, length: matchRange.location - lastRangeEnd)))
            
            let entityName = nsInput.substring(with: match.range(at: 1))
            let replacement: String
            switch entityName {
            case "amp":
                replacement = "&"
            case "lt":
                replacement = "<"
            case "gt":
                replacement = ">"
            case "nbsp":
                replacement = "\u{00A0}"
            default:
                // Leave unsupported entities unchanged.
                replacement = nsInput.substring(with: matchRange)
            }
            
            result.append(replacement)
            lastRangeEnd = matchRange.location + matchRange.length
        }
        // Append any remaining text.
        result.append(nsInput.substring(from: lastRangeEnd))
        return result
    }
}

// MARK: - Methods for Unit Test Compatibility

extension TextBlock {
    /// Sets the text after performing a single-pass HTML entity decode.
    func setText(_ newText: String) {
        self.text = TextBlock.decodeHTMLEntities(newText)
    }
    
    /// Returns the (decoded) text.
    func getText() -> String {
        return self.text
    }
}

// MARK: - Consolidated SwiftTextElementProperties Legacy Support

/// Unified legacy support for SwiftTextElementProperties parsing and serialization
enum SwiftTextElementPropertiesLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTextElementProperties
    static func deserialize(from value: [String: Any]) throws -> SwiftTextElementProperties {
        guard value["text"] is String else {
            throw SwiftAdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "text")
        }

        let data = try JSONSerialization.data(withJSONObject: value, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(SwiftTextElementProperties.self, from: data)
    }
    
    /// Deserializes string into a SwiftTextElementProperties
    static func deserialize(from jsonString: String) throws -> SwiftTextElementProperties {
        guard let data = jsonString.data(using: .utf8) else {
            throw SerializationError.stringDecodingFailed
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = json as? [String: Any] else {
            throw SerializationError.invalidJsonString
        }
        
        return try deserialize(from: jsonDict)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTextElementProperties to JSON dictionary with proper formatting
    static func serializeToJson(_ properties: SwiftTextElementProperties) -> [String: Any] {
        var json: [String: Any] = [:]

        // Add all non-nil properties
        if let textSize = properties.textSize {
            json["size"] = textSize.rawValue
        }
        if let textColor = properties.textColor {
            json["color"] = textColor.rawValue
        }
        if let textWeight = properties.textWeight {
            json["weight"] = textWeight.rawValue
        }
        if let fontType = properties.fontType {
            json["fontType"] = fontType.rawValue
        }
        if let isSubtle = properties.isSubtle {
            json["isSubtle"] = isSubtle
        }

        // Always include text and language
        json["text"] = properties.text
        json["language"] = properties.language

        return json
    }
    
    /// Serializes to JSON string
    static func serializeToJsonString(_ properties: SwiftTextElementProperties) throws -> String {
        let json = serializeToJson(properties)
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw SerializationError.stringEncodingFailed
        }
        return jsonString
    }
}

// MARK: - SwiftTextElementProperties Extension

extension SwiftTextElementProperties {
    // Legacy static factory methods
    
    /// Parses a `TextElementProperties` from a JSON dictionary.
    static func fromJSON(_ json: [String: Any]) throws -> SwiftTextElementProperties {
        return try SwiftTextElementPropertiesLegacySupport.deserialize(from: json)
    }
    
    /// Parses a `TextElementProperties` from a JSON string.
    static func fromJSONString(_ jsonString: String) throws -> SwiftTextElementProperties {
        return try SwiftTextElementPropertiesLegacySupport.deserialize(from: jsonString)
    }
    
    /// Serializes the properties to a JSON string
    func toJSONString() throws -> String {
        return try SwiftTextElementPropertiesLegacySupport.serializeToJsonString(self)
    }
}

import Foundation

// MARK: - TextRun Legacy Support

/// Unified legacy support for SwiftTextRun parsing and serialization
enum SwiftTextRunLegacySupport {
    // MARK: - Parsing Functions
    
    /// Deserializes JSON into a SwiftTextRun
    static func deserialize(from value: [String: Any]) throws -> SwiftTextRun? {
        // Use the existing deserialize method from SwiftTextRun
        return try SwiftTextRun.deserialize(from: value)
    }
    
    /// Deserializes string into a SwiftTextRun
    static func deserialize(from jsonString: String) throws -> SwiftTextRun? {
        guard let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw SwiftJSONError.missingKey("Invalid JSON string")
        }
        return try deserialize(from: json)
    }
    
    // MARK: - Serialization Functions
    
    /// Converts a SwiftTextRun to JSON dictionary with proper formatting
    static func serializeToJson(_ textRun: SwiftTextRun) -> [String: Any] {
        var json = textRun.additionalProperties.mapValues { $0.value }
        
        // Set type property
        json["type"] = SwiftInlineElementType.textRun.rawValue
        
        // Add required property
        json["text"] = textRun.text
        
        // Add optional properties
        if let textSize = textRun.textSize {
            json["textSize"] = textSize.rawValue
            json["size"] = textSize.rawValue // Alternate key for compatibility
        }
        
        if let textWeight = textRun.textWeight {
            json["textWeight"] = textWeight.rawValue
            json["weight"] = textWeight.rawValue // Alternate key for compatibility
        }
        
        if let fontType = textRun.fontType {
            json["fontType"] = fontType.rawValue
        }
        
        if let textColor = textRun.textColor {
            json["textColor"] = textColor.rawValue
            json["color"] = textColor.rawValue // Alternate key for compatibility
        }
        
        if let isSubtle = textRun.isSubtle {
            json["isSubtle"] = isSubtle
        }
        
        // Encode flags when true
        if textRun.italic { json["italic"] = true }
        if textRun.strikethrough { json["strikethrough"] = true }
        if textRun.highlight { json["highlight"] = true }
        if textRun.underline { json["underline"] = true }
        
        // Add language if present (with alternate key)
        if let language = textRun.language {
            json["language"] = language
            json["lang"] = language
        }
        
        // Add selectAction if present
        if let selectAction = textRun.selectAction {
            json["selectAction"] = try? SwiftBaseCardElement.serializeSelectAction(selectAction)
        }
        
        return json
    }
    
    /// Converts to JSON string
    static func serializeToJsonString(_ textRun: SwiftTextRun) throws -> String {
        let json = serializeToJson(textRun)
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw EncodingError.invalidValue(json, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to convert JSON to string"))
        }
        return jsonString
    }
}

// MARK: - SwiftTextRun Extension for Deserialization

extension SwiftTextRun {
    /// Static method to deserialize from a JSON dictionary
    static func deserialize(from json: [String: Any]) throws -> SwiftTextRun? {
        guard let text = json["text"] as? String else { return nil }
        
        // Create a mutable copy of additional properties
        var additionalProperties = json
        additionalProperties.removeValue(forKey: "type")
        additionalProperties.removeValue(forKey: "text")
        additionalProperties.removeValue(forKey: "selectAction")
        
        // Mapping for legacy keys
        let sizeString = json["textSize"] as? String ?? json["size"] as? String
        let textSize = sizeString.flatMap { SwiftTextSize.fromString($0) }
        
        let textWeight = (json["textWeight"] as? String ?? json["weight"] as? String)
            .flatMap { SwiftTextWeight(rawValue: $0) }
        
        let fontType = (json["fontType"] as? String)
            .flatMap { SwiftFontType(rawValue: $0) }
        
        let textColor = (json["textColor"] as? String ?? json["color"] as? String)
            .flatMap { SwiftForegroundColor.fromString($0) }
        
        let isSubtle = json["isSubtle"] as? Bool
        
        let italic = json["italic"] as? Bool ?? false
        let strikethrough = json["strikethrough"] as? Bool ?? false
        let highlight = json["highlight"] as? Bool ?? false
        let underline = json["underline"] as? Bool ?? false
        
        // Language handling with fallback
        let language = json["language"] as? String ?? json["lang"] as? String
        
        // Handle selectAction
        let selectAction: SwiftBaseActionElement?
        if let actionData = json["selectAction"] {
            if let dict = actionData as? [String: AnyCodable],
               let typeAnyCodable = dict["type"],
               let typeString = typeAnyCodable.value as? String {
                let actionDict: [String: Any] = ["type": typeString]
                selectAction = try SwiftBaseActionElement.deserializeAction(from: actionDict)
            } else {
                selectAction = nil
            }
        } else {
            selectAction = nil
        }
        
        // Remove keys that have been processed
        additionalProperties.removeValue(forKey: "textSize")
        additionalProperties.removeValue(forKey: "size")
        additionalProperties.removeValue(forKey: "weight")
        additionalProperties.removeValue(forKey: "textWeight")
        additionalProperties.removeValue(forKey: "fontType")
        additionalProperties.removeValue(forKey: "textColor")
        additionalProperties.removeValue(forKey: "color")
        additionalProperties.removeValue(forKey: "isSubtle")
        additionalProperties.removeValue(forKey: "italic")
        additionalProperties.removeValue(forKey: "strikethrough")
        additionalProperties.removeValue(forKey: "highlight")
        additionalProperties.removeValue(forKey: "underline")
        additionalProperties.removeValue(forKey: "language")
        additionalProperties.removeValue(forKey: "lang")
        
        return SwiftTextRun(
            text: text,
            textSize: textSize,
            textWeight: textWeight,
            fontType: fontType,
            textColor: textColor,
            isSubtle: isSubtle,
            italic: italic,
            strikethrough: strikethrough,
            highlight: highlight,
            underline: underline,
            language: language ?? "en", // Default to "en" if nil
            selectAction: selectAction,
            additionalProperties: additionalProperties.mapValues { AnyCodable($0) }
        )
    }
}

// MARK: - Convenience Extension

extension SwiftTextRun {
    /// Serializes the text run to a JSON dictionary
    func serializeToJson() -> [String: Any] {
        return SwiftTextRunLegacySupport.serializeToJson(self)
    }
    
    /// Serializes the text run to a JSON string
    func serializeToJsonString() throws -> String {
        return try SwiftTextRunLegacySupport.serializeToJsonString(self)
    }
}
