import Foundation

protocol ActionElementParser {
    func deserialize(context: inout ParseContext, from json: [String: Any]) throws -> BaseActionElement
    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement
}

// Wrapper for an existing ActionElementParser to enforce ID collision detection
final class ActionElementParserWrapper: ActionElementParser {
    private let parser: ActionElementParser

    init(parser: ActionElementParser) {
        self.parser = parser
    }

    func deserialize(context: inout ParseContext, from json: [String: Any]) throws -> BaseActionElement {
        guard let idProperty = json["id"] as? String else {
            throw AdaptiveCardParseException(statusCode: .requiredPropertyMissing, message: "Missing id property")
        }
        
        let internalId = InternalId.next()
        context.pushElement(id: idProperty, internalId: internalId)
        
        let element = try parser.deserialize(context: &context, from: json)
        context.popElement()
        
        return element
    }

    func deserialize(fromString jsonString: String, context: inout ParseContext) throws -> BaseActionElement {
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw AdaptiveCardParseException(statusCode: .invalidJson, message: "Invalid JSON string")
        }
        return try deserialize(context: &context, from: json)
    }
}

final class ActionParserRegistration {
    private var knownElements: Set<String> = []
    private var cardElementParsers: [String: ActionElementParser] = [:]

    init() {
        let defaultParsers: [(String, ActionElementParser)] = [
            (ActionType.execute.rawValue, ExecuteActionParser()),
            (ActionType.openUrl.rawValue, OpenUrlActionParser()),
            (ActionType.showCard.rawValue, ShowCardActionParser()),
            (ActionType.submit.rawValue, SubmitActionParser()),
            (ActionType.toggleVisibility.rawValue, ToggleVisibilityActionParser()),
            (ActionType.unknownAction.rawValue, UnknownActionParser())
        ]

        for (key, parser) in defaultParsers {
            knownElements.insert(key)
            cardElementParsers[key] = parser
        }
    }

    func addParser(for elementType: String, parser: ActionElementParser) throws {
        guard !knownElements.contains(elementType) else {
            throw AdaptiveCardParseException(statusCode: .unsupportedParserOverride, message: "Overriding known action parsers is unsupported")
        }
        cardElementParsers[elementType] = parser
    }

    func removeParser(for elementType: String) throws {
        guard !knownElements.contains(elementType) else {
            throw AdaptiveCardParseException(statusCode: .unsupportedParserOverride, message: "Removing known action parsers is unsupported")
        }
        cardElementParsers.removeValue(forKey: elementType)
    }

    func getParser(for elementType: String) -> ActionElementParser? {
        guard let parser = cardElementParsers[elementType] else {
            return nil
        }
        return ActionElementParserWrapper(parser: parser)
    }
}
