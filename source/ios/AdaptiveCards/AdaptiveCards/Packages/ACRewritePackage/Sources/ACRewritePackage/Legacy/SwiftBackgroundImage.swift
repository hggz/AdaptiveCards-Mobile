import Foundation

/// Represents a background image in an Adaptive Card.
struct SwiftBackgroundImage: Codable {
    // MARK: - Properties
    let url: String
    let fillMode: SwiftImageFillMode
    let horizontalAlignment: SwiftHorizontalAlignment
    let verticalAlignment: SwiftVerticalAlignment
    
    // MARK: - Initialization
    init(
        url: String = "",
        fillMode: SwiftImageFillMode = .cover,
        horizontalAlignment: SwiftHorizontalAlignment = .left,
        verticalAlignment: SwiftVerticalAlignment = .top
    ) {
        self.url = url
        self.fillMode = fillMode
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
    }
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case url, fillMode, horizontalAlignment, verticalAlignment
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode url with default
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        
        // Case-insensitive enum parsing for fillMode
        let fillModeStr = try container.decodeIfPresent(String.self, forKey: .fillMode)?.lowercased() ?? "cover"
        
        // Map common variations for fillMode
        let fillModeMap: [String: SwiftImageFillMode] = [
            "repeathorizontally": .repeatHorizontally,
            "repeat-horizontally": .repeatHorizontally,
            "repeat_horizontally": .repeatHorizontally
        ]
        
        fillMode = fillModeMap[fillModeStr] ?? SwiftImageFillMode(rawValue: fillModeStr) ?? .cover
        
        // Decode alignment values with defaults
        let horizontalStr = try container.decodeIfPresent(String.self, forKey: .horizontalAlignment)?.lowercased() ?? "left"
        horizontalAlignment = SwiftHorizontalAlignment(rawValue: horizontalStr) ?? .left
        
        let verticalStr = try container.decodeIfPresent(String.self, forKey: .verticalAlignment)?.lowercased() ?? "top"
        verticalAlignment = SwiftVerticalAlignment(rawValue: verticalStr) ?? .top
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(url, forKey: .url)
        
        // Use specified enum cases for fillMode
        switch fillMode {
        case .repeatHorizontally:
            try container.encode("repeatHorizontally", forKey: .fillMode)
        default:
            try container.encode(fillMode.rawValue.lowercased(), forKey: .fillMode)
        }
        
        try container.encode(horizontalAlignment.rawValue.lowercased(), forKey: .horizontalAlignment)
        try container.encode(verticalAlignment.rawValue.lowercased(), forKey: .verticalAlignment)
    }
}
