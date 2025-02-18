import Foundation

struct BackgroundImage: Codable {
    var url: String
    var fillMode: ImageFillMode
    var horizontalAlignment: HorizontalAlignment
    var verticalAlignment: VerticalAlignment

    init(
        url: String = "",
        fillMode: ImageFillMode = .cover,
        horizontalAlignment: HorizontalAlignment = .left,
        verticalAlignment: VerticalAlignment = .top
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
    
    static func deserialize(from json: [String: Any]) throws -> BackgroundImage {
        guard let url = json["url"] as? String else { return BackgroundImage() }
        
        // Case-insensitive enum parsing
        let fillModeStr = (json["fillMode"] as? String ?? "cover").lowercased()
        let horizontalStr = (json["horizontalAlignment"] as? String ?? "left").lowercased()
        let verticalStr = (json["verticalAlignment"] as? String ?? "top").lowercased()
        
        // Map common variations
        let fillModeMap: [String: ImageFillMode] = [
            "repeathorizontally": .repeatHorizontally,
            "repeat-horizontally": .repeatHorizontally,
            "repeat_horizontally": .repeatHorizontally
        ]
        
        let fillMode = fillModeMap[fillModeStr] ?? ImageFillMode(rawValue: fillModeStr) ?? .cover
        let horizontalAlignment = HorizontalAlignment(rawValue: horizontalStr) ?? .left
        let verticalAlignment = VerticalAlignment(rawValue: verticalStr) ?? .top
        
        return BackgroundImage(
            url: url,
            fillMode: fillMode,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment
        )
    }
    
    static func deserialize(from jsonString: String) -> BackgroundImage? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return try? deserialize(from: jsonDict)
    }
}
