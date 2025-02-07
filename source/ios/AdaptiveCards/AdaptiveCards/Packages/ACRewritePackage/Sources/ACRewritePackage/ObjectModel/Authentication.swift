import Foundation

struct Authentication: Codable {
    var text: String
    var connectionName: String
    var tokenExchangeResource: TokenExchangeResource?
    var buttons: [AuthCardButton]

    init(
        text: String = "",
        connectionName: String = "",
        tokenExchangeResource: TokenExchangeResource? = nil,
        buttons: [AuthCardButton] = []
    ) {
        self.text = text
        self.connectionName = connectionName
        self.tokenExchangeResource = tokenExchangeResource
        self.buttons = buttons
    }

    func shouldSerialize() -> Bool {
        return !text.isEmpty ||
               !connectionName.isEmpty ||
               !buttons.isEmpty ||
        (tokenExchangeResource?.shouldSerialize ?? false)
    }

    func serialize() -> String {
        let jsonData = try? JSONEncoder().encode(self)
        return jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    func serializeToJsonValue() throws -> [String: Any] {
        var json: [String: Any] = [:]

        if !text.isEmpty {
            json["text"] = text
        }
        if !connectionName.isEmpty {
            json["connectionName"] = connectionName
        }
        if let tokenExchangeResource = tokenExchangeResource, tokenExchangeResource.shouldSerialize {
            json["tokenExchangeResource"] = try tokenExchangeResource.serializeToJsonValue()
        }
        if !buttons.isEmpty {
            json["buttons"] = buttons.map { $0.serializeToJsonValue() }
        }

        return json
    }

    static func deserialize(from json: [String: Any]) throws -> Authentication {
        return Authentication(
            text: json["text"] as? String ?? "",
            connectionName: json["connectionName"] as? String ?? "",
            tokenExchangeResource: try (json["tokenExchangeResource"] as? [String: Any]).flatMap { try TokenExchangeResource.deserialize(from: $0) },
            buttons: (json["buttons"] as? [[String: Any]])?.compactMap { AuthCardButton.deserialize(from: $0) } ?? []
        )
    }

    static func deserialize(from jsonString: String) -> Authentication? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return try? deserialize(from: jsonDict)
    }
}
