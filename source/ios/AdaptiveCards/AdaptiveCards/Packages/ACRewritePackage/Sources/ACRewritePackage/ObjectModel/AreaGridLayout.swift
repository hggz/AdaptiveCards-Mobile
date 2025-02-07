import Foundation

struct AreaGridLayout: Codable {
    var columns: [String] = []
    var areas: [GridArea] = []
    var rowSpacing: Spacing = .default
    var columnSpacing: Spacing = .default

    init() {}

    init(columns: [String], areas: [GridArea], rowSpacing: Spacing = .default, columnSpacing: Spacing = .default) {
        self.columns = columns
        self.areas = areas
        self.rowSpacing = rowSpacing
        self.columnSpacing = columnSpacing
    }

    func shouldSerialize() -> Bool {
        return true
    }

    func serialize() -> String {
        let jsonData = try? JSONEncoder().encode(self)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    func serializeToJsonValue() -> [String: Any] {
        var json: [String: Any] = [:]

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

    static func deserialize(from json: [String: Any]) -> AreaGridLayout {
        var layout = AreaGridLayout()

        if let columnArray = json["columns"] as? [String] {
            layout.columns = columnArray
        }

        if let areaArray = json["areas"] as? [[String: Any]] {
            layout.areas = areaArray.map { GridArea.deserialize(from: $0) }
        }

        if let rowSpacingStr = json["rowSpacing"] as? String,
           let spacingEnum = Spacing(rawValue: rowSpacingStr) {
            layout.rowSpacing = spacingEnum
        }

        if let columnSpacingStr = json["columnSpacing"] as? String,
           let spacingEnum = Spacing(rawValue: columnSpacingStr) {
            layout.columnSpacing = spacingEnum
        }

        return layout
    }

    static func deserialize(from jsonString: String) -> AreaGridLayout? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonDict)
    }
}
