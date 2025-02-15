import Foundation

enum ItemFit: String, Codable {
    case Fit, Fill
}

class FlowLayout: Layout {
    var itemFit: ItemFit = .Fit
    var itemWidth: String?
    var minItemWidth: String?
    var maxItemWidth: String?
    var itemPixelWidth: Int = -1
    var minItemPixelWidth: Int = -1
    var maxItemPixelWidth: Int = -1
    var rowSpacing: Spacing = .default
    var columnSpacing: Spacing = .default
    var horizontalAlignment: HorizontalAlignment = .center

    override init() {
        super.init()
        layoutContainerType = .flow
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.itemFit = try container.decodeIfPresent(ItemFit.self, forKey: .itemFit) ?? .Fit
        self.itemWidth = try container.decodeIfPresent(String.self, forKey: .itemWidth)
        self.minItemWidth = try container.decodeIfPresent(String.self, forKey: .minItemWidth)
        self.maxItemWidth = try container.decodeIfPresent(String.self, forKey: .maxItemWidth)
        self.rowSpacing = try container.decodeIfPresent(Spacing.self, forKey: .rowSpacing) ?? .default
        self.columnSpacing = try container.decodeIfPresent(Spacing.self, forKey: .columnSpacing) ?? .default
        self.horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment) ?? .center
        self.itemPixelWidth = FlowLayout.parseSizeToPixels(try container.decodeIfPresent(String.self, forKey: .itemWidth)) ?? -1
        self.minItemPixelWidth = FlowLayout.parseSizeToPixels(try container.decodeIfPresent(String.self, forKey: .minItemWidth)) ?? -1
        self.maxItemPixelWidth = FlowLayout.parseSizeToPixels(try container.decodeIfPresent(String.self, forKey: .maxItemWidth)) ?? -1
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if itemFit != .Fit {
            try container.encode(itemFit, forKey: .itemFit)
        }
        try container.encodeIfPresent(itemWidth, forKey: .itemWidth)
        try container.encodeIfPresent(minItemWidth, forKey: .minItemWidth)
        try container.encodeIfPresent(maxItemWidth, forKey: .maxItemWidth)
        if rowSpacing != .default {
            try container.encode(rowSpacing, forKey: .rowSpacing)
        }
        if columnSpacing != .default {
            try container.encode(columnSpacing, forKey: .columnSpacing)
        }
        if horizontalAlignment != .center {
            try container.encode(horizontalAlignment, forKey: .horizontalAlignment)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case itemFit, itemWidth, minItemWidth, maxItemWidth, rowSpacing, columnSpacing, horizontalAlignment
    }
    
    static func parseSizeToPixels(_ size: String?) -> Int? {
        guard let size = size else { return nil }
        return Int(size.replacingOccurrences(of: "px", with: ""))
    }
    
    class func deserialize(from json: [String: Any]) throws -> FlowLayout {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(FlowLayout.self, from: data)
    }
}
