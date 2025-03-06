import Foundation

/// Represents an area grid layout in an Adaptive Card.
class SwiftAreaGridLayout: SwiftLayout {
    // MARK: - Properties
    var columns: [String] = []
    var areas: [SwiftGridArea] = []
    var rowSpacing: SwiftSpacing = .default
    var columnSpacing: SwiftSpacing = .default
    
    // MARK: - Initialization
    override init() {
        super.init()
        self.layoutContainerType = .areaGrid
    }
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case columns, areas, rowSpacing, columnSpacing
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        columns = try container.decodeIfPresent([String].self, forKey: .columns) ?? []
        areas = try container.decodeIfPresent([SwiftGridArea].self, forKey: .areas) ?? []
        rowSpacing = try container.decodeIfPresent(SwiftSpacing.self, forKey: .rowSpacing) ?? .default
        columnSpacing = try container.decodeIfPresent(SwiftSpacing.self, forKey: .columnSpacing) ?? .default
        
        // Call super.init after initializing all properties
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
}
