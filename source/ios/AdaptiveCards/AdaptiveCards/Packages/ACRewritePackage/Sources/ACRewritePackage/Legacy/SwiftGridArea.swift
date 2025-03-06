import Foundation

struct SwiftGridArea: Codable {
    // MARK: - Properties
    let name: String
    let row: Int
    let column: Int
    let rowSpan: Int
    let columnSpan: Int
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case name, row, column, rowSpan, columnSpan
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        row = try container.decodeIfPresent(Int.self, forKey: .row) ?? 1
        column = try container.decodeIfPresent(Int.self, forKey: .column) ?? 1
        rowSpan = try container.decodeIfPresent(Int.self, forKey: .rowSpan) ?? 1
        columnSpan = try container.decodeIfPresent(Int.self, forKey: .columnSpan) ?? 1
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(row, forKey: .row)
        try container.encode(column, forKey: .column)
        try container.encode(rowSpan, forKey: .rowSpan)
        try container.encode(columnSpan, forKey: .columnSpan)
    }
    
    // MARK: - Serialization to JSON
    func serializeToJson() -> [String: Any] {
        return SwiftGridAreaLegacySupport.serializeToJson(self)
    }
    
    func serializeToString() -> String {
        return SwiftGridAreaLegacySupport.serializeToString(self)
    }
    
    // MARK: - Initialization with Default Values
    
    // This initializer is needed to support direct creation and maintain compatibility with existing code
    init(name: String = "", row: Int = 1, column: Int = 1, rowSpan: Int = 1, columnSpan: Int = 1) {
        self.name = name
        self.row = row
        self.column = column
        self.rowSpan = rowSpan
        self.columnSpan = columnSpan
    }
}
