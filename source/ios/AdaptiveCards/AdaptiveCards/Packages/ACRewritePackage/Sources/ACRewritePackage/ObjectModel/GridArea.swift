import Foundation

struct GridArea: Codable {
    var name: String
    var row: Int
    var column: Int
    var rowSpan: Int
    var columnSpan: Int
    
    init(name: String = "", row: Int = 1, column: Int = 1, rowSpan: Int = 1, columnSpan: Int = 1) {
        self.name = name
        self.row = row
        self.column = column
        self.rowSpan = rowSpan
        self.columnSpan = columnSpan
    }
    
    // Serialization to JSON
    func serializeToJson() -> [String: Any] {
        return [
            "name": name,
            "row": row,
            "column": column,
            "rowSpan": rowSpan,
            "columnSpan": columnSpan
        ]
    }
    
    func serializeToString() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: serializeToJson(), options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            return "{}"
        }
    }
    
    // Deserialization from JSON
    static func deserialize(from json: [String: Any]) -> GridArea {
        return GridArea(
            name: json["name"] as? String ?? "",
            row: json["row"] as? Int ?? 1,
            column: json["column"] as? Int ?? 1,
            rowSpan: json["rowSpan"] as? Int ?? 1,
            columnSpan: json["columnSpan"] as? Int ?? 1
        )
    }
    
    static func deserialize(from jsonString: String) -> GridArea? {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
        return deserialize(from: jsonDict)
    }
}
