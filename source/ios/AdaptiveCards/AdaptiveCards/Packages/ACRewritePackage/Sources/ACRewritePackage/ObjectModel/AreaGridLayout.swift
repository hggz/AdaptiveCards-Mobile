import Foundation

class AreaGridLayout: Layout {
    var columns: [String] = []
    var areas: [GridArea] = []
    var rowSpacing: Spacing = .default
    var columnSpacing: Spacing = .default

    override init() {
        super.init()
        self.layoutContainerType = .areaGrid
    }
    
    init(columns: [String], areas: [GridArea], rowSpacing: Spacing = .default, columnSpacing: Spacing = .default) {
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
        self.areas = try container.decodeIfPresent([GridArea].self, forKey: .areas) ?? []
        self.rowSpacing = try container.decodeIfPresent(Spacing.self, forKey: .rowSpacing) ?? .default
        self.columnSpacing = try container.decodeIfPresent(Spacing.self, forKey: .columnSpacing) ?? .default
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
    
    class func deserialize(from json: [String: Any]) -> AreaGridLayout {
        let instance = AreaGridLayout()
        if let columnArray = json["columns"] as? [String] {
            instance.columns = columnArray
        }
        if let areaArray = json["areas"] as? [[String: Any]] {
            instance.areas = areaArray.map { GridArea.deserialize(from: $0) }
        }
        if let rowSpacingStr = json["rowSpacing"] as? String,
           let spacingEnum = Spacing(rawValue: rowSpacingStr) {
            instance.rowSpacing = spacingEnum
        }
        if let columnSpacingStr = json["columnSpacing"] as? String,
           let spacingEnum = Spacing(rawValue: columnSpacingStr) {
            instance.columnSpacing = spacingEnum
        }
        return instance
    }
}
