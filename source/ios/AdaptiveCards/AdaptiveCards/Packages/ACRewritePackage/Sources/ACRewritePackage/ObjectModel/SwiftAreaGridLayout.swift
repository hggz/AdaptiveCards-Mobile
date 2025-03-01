import Foundation

class SwiftAreaGridLayout: SwiftLayout {
    var columns: [String] = []
    var areas: [SwiftGridArea] = []
    var rowSpacing: SwiftSpacing = .default
    var columnSpacing: SwiftSpacing = .default

    override init() {
        super.init()
        self.layoutContainerType = .areaGrid
    }
    
    init(columns: [String], areas: [SwiftGridArea], rowSpacing: SwiftSpacing = .default, columnSpacing: SwiftSpacing = .default) {
        self.columns = columns
        self.areas = areas
        self.rowSpacing = rowSpacing
        self.columnSpacing = columnSpacing
        super.init()
        self.layoutContainerType = .areaGrid
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.columns = try container.decodeIfPresent([String].self, forKey: .columns) ?? []
        self.areas = try container.decodeIfPresent([SwiftGridArea].self, forKey: .areas) ?? []
        self.rowSpacing = try container.decodeIfPresent(SwiftSpacing.self, forKey: .rowSpacing) ?? .default
        self.columnSpacing = try container.decodeIfPresent(SwiftSpacing.self, forKey: .columnSpacing) ?? .default
        try super.init(from: decoder)
        self.layoutContainerType = .areaGrid
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(columns, forKey: .columns)
        try container.encode(areas, forKey: .areas)
        try container.encode(rowSpacing, forKey: .rowSpacing)
        try container.encode(columnSpacing, forKey: .columnSpacing)
        try super.encode(to: encoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case columns, areas, rowSpacing, columnSpacing
    }
    
    override func serializeToJsonValue() -> [String: Any] {
        var json = super.serializeToJsonValue()
        if !areas.isEmpty {
            json["areas"] = areas.map { $0.serializeToJson() }
        }
        if !columns.isEmpty {
            json["columns"] = columns
        }
        if rowSpacing != .default {
            json["rowSpacing"] = rowSpacing.rawValue
        }
        if columnSpacing != .default {
            json["columnSpacing"] = columnSpacing.rawValue
        }
        return json
    }
    
    class func deserialize(from json: [String: Any]) -> SwiftAreaGridLayout {
        let instance = SwiftAreaGridLayout()
        if let columnArray = json["columns"] as? [String] {
            instance.columns = columnArray
        }
        if let areaArray = json["areas"] as? [[String: Any]] {
            instance.areas = areaArray.map { SwiftGridArea.deserialize(from: $0) }
        }
        if let rowSpacingStr = json["rowSpacing"] as? String,
           let spacingEnum = SwiftSpacing(rawValue: rowSpacingStr) {
            instance.rowSpacing = spacingEnum
        }
        if let columnSpacingStr = json["columnSpacing"] as? String,
           let spacingEnum = SwiftSpacing(rawValue: columnSpacingStr) {
            instance.columnSpacing = spacingEnum
        }
        return instance
    }
}
