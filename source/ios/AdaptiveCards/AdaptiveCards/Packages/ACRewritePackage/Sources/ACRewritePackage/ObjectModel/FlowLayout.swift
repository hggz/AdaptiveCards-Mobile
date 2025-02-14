import Foundation

enum ItemFit: String, Codable {
    case Fit, Fill
}

struct FlowLayout: Codable {
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

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        itemFit = try container.decodeIfPresent(ItemFit.self, forKey: .itemFit) ?? .Fit
        itemWidth = try container.decodeIfPresent(String.self, forKey: .itemWidth)
        minItemWidth = try container.decodeIfPresent(String.self, forKey: .minItemWidth)
        maxItemWidth = try container.decodeIfPresent(String.self, forKey: .maxItemWidth)
        rowSpacing = try container.decodeIfPresent(Spacing.self, forKey: .rowSpacing) ?? .default
        columnSpacing = try container.decodeIfPresent(Spacing.self, forKey: .columnSpacing) ?? .default
        horizontalAlignment = try container.decodeIfPresent(HorizontalAlignment.self, forKey: .horizontalAlignment) ?? .center
        itemPixelWidth = FlowLayout.parseSizeToPixels(try container.decodeIfPresent(String.self, forKey: .itemWidth)) ?? -1
        minItemPixelWidth = FlowLayout.parseSizeToPixels(try container.decodeIfPresent(String.self, forKey: .minItemWidth)) ?? -1
        maxItemPixelWidth = FlowLayout.parseSizeToPixels(try container.decodeIfPresent(String.self, forKey: .maxItemWidth)) ?? -1
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if itemFit != .Fit { try container.encode(itemFit, forKey: .itemFit) }
        try container.encodeIfPresent(itemWidth, forKey: .itemWidth)
        try container.encodeIfPresent(minItemWidth, forKey: .minItemWidth)
        try container.encodeIfPresent(maxItemWidth, forKey: .maxItemWidth)
        if rowSpacing != .default { try container.encode(rowSpacing, forKey: .rowSpacing) }
        if columnSpacing != .default { try container.encode(columnSpacing, forKey: .columnSpacing) }
        if horizontalAlignment != .center { try container.encode(horizontalAlignment, forKey: .horizontalAlignment) }
    }

    static func deserialize(from json: String) throws -> FlowLayout {
        let jsonData = json.data(using: .utf8)!
        return try JSONDecoder().decode(FlowLayout.self, from: jsonData)
    }

    static func parseSizeToPixels(_ size: String?) -> Int? {
        guard let size = size else { return nil }
        return Int(size.replacingOccurrences(of: "px", with: ""))
    }

    private enum CodingKeys: String, CodingKey {
        case itemFit = "itemFit"
        case itemWidth = "itemWidth"
        case minItemWidth = "minItemWidth"
        case maxItemWidth = "maxItemWidth"
        case rowSpacing = "rowSpacing"
        case columnSpacing = "columnSpacing"
        case horizontalAlignment = "horizontalItemsAlignment"
    }
    
    static func deserialize(from json: [String: Any]) throws -> FlowLayout {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try JSONDecoder().decode(FlowLayout.self, from: data)
    }
}
