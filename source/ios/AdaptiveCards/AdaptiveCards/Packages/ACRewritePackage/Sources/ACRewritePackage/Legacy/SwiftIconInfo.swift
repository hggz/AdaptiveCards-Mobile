import Foundation

struct SwiftIconInfo: Codable {
    // MARK: - Properties
    let name: String?
    let foregroundColor: SwiftForegroundColor
    let iconSize: SwiftIconSize
    let iconStyle: SwiftIconStyle

    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case name
        case foregroundColor = "color"
        case iconSize = "size"
        case iconStyle = "style"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties
        name = try container.decodeIfPresent(String.self, forKey: .name)
        foregroundColor = try container.decodeIfPresent(SwiftForegroundColor.self, forKey: .foregroundColor) ?? .default
        iconSize = try container.decodeIfPresent(SwiftIconSize.self, forKey: .iconSize) ?? .standard
        iconStyle = try container.decodeIfPresent(SwiftIconStyle.self, forKey: .iconStyle) ?? .regular
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        
        // Only encode non-default values
        if foregroundColor != .default {
            try container.encode(foregroundColor, forKey: .foregroundColor)
        }
        
        if iconSize != .standard {
            try container.encode(iconSize, forKey: .iconSize)
        }
        
        if iconStyle != .regular {
            try container.encode(iconStyle, forKey: .iconStyle)
        }
    }
    
    // MARK: - Utility Methods
    
    // Get SVG Path
    func getSVGPath() -> String {
        guard let name = name else { return "" }
        return "\(name)/\(name).json"
    }
}
