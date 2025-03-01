import Foundation

struct SwiftBackgroundImage: Codable {
    var url: String
    var fillMode: SwiftImageFillMode
    var horizontalAlignment: SwiftHorizontalAlignment
    var verticalAlignment: SwiftVerticalAlignment

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

    func shouldSerialize() -> Bool {
        return !url.isEmpty
    }

    func serialize() -> String {
        let jsonData = try? JSONEncoder().encode(self)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    func serializeToJsonValue() -> [String: Any] {
        var json: [String: Any] = ["url": url]
        
        // Use specified enum cases from the test
        switch fillMode {
        case .repeatHorizontally:
            json["fillMode"] = "repeatHorizontally"
        default:
            json["fillMode"] = fillMode.rawValue.lowercased()
        }
        
        json["horizontalAlignment"] = horizontalAlignment.rawValue.lowercased()
        json["verticalAlignment"] = verticalAlignment.rawValue.lowercased()
        return json
    }
    
    static func deserialize(from json: [String: Any]) throws -> SwiftBackgroundImage {
        guard let url = json["url"] as? String else { return SwiftBackgroundImage() }
        
        // Case-insensitive enum parsing
        let fillModeStr = (json["fillMode"] as? String ?? "cover").lowercased()
        let horizontalStr = (json["horizontalAlignment"] as? String ?? "left").lowercased()
        let verticalStr = (json["verticalAlignment"] as? String ?? "top").lowercased()
        
        // Map common variations
        let fillModeMap: [String: SwiftImageFillMode] = [
            "repeathorizontally": .repeatHorizontally,
            "repeat-horizontally": .repeatHorizontally,
            "repeat_horizontally": .repeatHorizontally
        ]
        
        let fillMode = fillModeMap[fillModeStr] ?? SwiftImageFillMode(rawValue: fillModeStr) ?? .cover
        let horizontalAlignment = SwiftHorizontalAlignment(rawValue: horizontalStr) ?? .left
        let verticalAlignment = SwiftVerticalAlignment(rawValue: verticalStr) ?? .top
        
        return SwiftBackgroundImage(
            url: url,
            fillMode: fillMode,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment
        )
    }
    
    static func deserialize(from jsonString: String) -> SwiftBackgroundImage? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return try? deserialize(from: jsonDict)
    }
}
