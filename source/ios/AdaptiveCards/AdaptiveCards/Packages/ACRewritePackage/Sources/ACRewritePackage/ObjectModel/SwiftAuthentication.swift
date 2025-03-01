import Foundation

struct SwiftAuthentication: Codable {
    var text: String
    var connectionName: String
    var tokenExchangeResource: SwiftTokenExchangeResource?
    var buttons: [SwiftAuthCardButton]

    init(
        text: String = "",
        connectionName: String = "",
        tokenExchangeResource: SwiftTokenExchangeResource? = nil,
        buttons: [SwiftAuthCardButton] = []
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

    static func deserialize(from json: [String: Any]) throws -> SwiftAuthentication {
        return SwiftAuthentication(
            text: json["text"] as? String ?? "",
            connectionName: json["connectionName"] as? String ?? "",
            tokenExchangeResource: try (json["tokenExchangeResource"] as? [String: Any]).flatMap { try SwiftTokenExchangeResource.deserialize(from: $0) },
            buttons: (json["buttons"] as? [[String: Any]])?.compactMap { SwiftAuthCardButton.deserialize(from: $0) } ?? []
        )
    }

    static func deserialize(from jsonString: String) -> SwiftAuthentication? {
        guard let jsonData = jsonString.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return try? deserialize(from: jsonDict)
    }
}
