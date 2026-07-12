import Foundation

/// Canonical "Hello World" Adaptive Card payload published at
/// https://adaptivecards.io/samples/ . Embedded verbatim so the runtime proof
/// consumes a real card shape rather than a synthetic domain object.
enum SampleCard {
    static let helloWorldJSON = """
    {
        "type": "AdaptiveCard",
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "version": "1.5",
        "body": [
            {
                "type": "TextBlock",
                "text": "Hello, World!"
            }
        ]
    }
    """

    struct FirstElement: Equatable {
        let type: String
        let text: String
    }

    static func firstElement() throws -> FirstElement {
        let data = Data(helloWorldJSON.utf8)
        guard
            let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            root["type"] as? String == "AdaptiveCard",
            root["version"] as? String == "1.5",
            let body = root["body"] as? [[String: Any]],
            let first = body.first,
            let type = first["type"] as? String,
            let text = first["text"] as? String
        else {
            throw DemoError.invalidCard
        }
        return FirstElement(type: type, text: text)
    }
}

enum DemoError: Error, CustomStringConvertible {
    case invalidCard
    case assertion(String)

    var description: String {
        switch self {
        case .invalidCard: return "canonical Adaptive Card could not be decoded"
        case .assertion(let message): return message
        }
    }
}
