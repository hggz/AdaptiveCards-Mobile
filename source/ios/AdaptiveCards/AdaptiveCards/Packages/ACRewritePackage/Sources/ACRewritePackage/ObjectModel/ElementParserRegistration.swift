import Foundation

/// Protocol for parsing Adaptive Card elements.
protocol BaseCardElementParser {
    func deserialize(context: ParseContext, value: [String: Any]) throws -> BaseCardElement
    func deserialize(fromString context: ParseContext, value: String) throws -> BaseCardElement
}

/// Wrapper for a `BaseCardElementParser` to handle ID collision detection in `ParseContext`.
// BaseCardElementParser.swift
struct BaseCardElementParserWrapper: BaseCardElementParser {
    private let parser: BaseCardElementParser
    var actualParser: BaseCardElementParser { return parser }
    
    init(parser: BaseCardElementParser) {
        self.parser = parser
    }
    
    func deserialize(context: ParseContext, value: [String: Any]) throws -> BaseCardElement {
        let idProperty = value["id"] as? String ?? ""
        let internalId = InternalId.next()
        context.pushElement(idJsonProperty: idProperty, internalId: internalId)
        let element = try parser.deserialize(context: context, value: value)
        context.popElement()
        return element
    }
    
    func deserialize(fromString context: ParseContext, value: String) throws -> BaseCardElement {
        guard let jsonData = value.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserialize(context: context, value: jsonDict)
    }
}

/// Manages the registration of element parsers.
struct ElementParserRegistration {
    private var knownElements: Set<String> = []
    private var cardElementParsers: [String: BaseCardElementParser] = [:]

    init() {
        knownElements = [
            "ActionSet", "ChoiceSetInput", "Column", "ColumnSet", "CompoundButton",
            "Container", "DateInput", "FactSet", "Image", "Icon", "ImageSet",
            "Media", "NumberInput", "RatingInput", "RatingLabel", "RichTextBlock",
            "Table", "TextBlock", "TextInput", "TimeInput", "ToggleInput", "Unknown"
        ]

        cardElementParsers = [
            "ActionSet": ActionSetParser(),
            "ChoiceSetInput": ChoiceSetInputParser(),
            "Column": ColumnParser(),
            "ColumnSet": ColumnSetParser(),
            "Container": ContainerParser(),
            "DateInput": DateInputParser(),
            "FactSet": FactSetParser(),
            "Image": ImageParser(),
            "Icon": IconParser(),
            "ImageSet": ImageSetParser(),
            "Media": MediaParser(),
            "NumberInput": NumberInputParser(),
            "RatingInput": RatingInputParser(),
            "RatingLabel": RatingLabelParser(),
            "RichTextBlock": RichTextBlockParser(),
            "Table": TableParser(),
            "TextBlock": TextBlockParser(),
            "TextInput": TextInputParser(),
            "TimeInput": TimeInputParser(),
            "ToggleInput": ToggleInputParser(),
            "CompoundButton": CompoundButtonParser(),
            "Unknown": UnknownElementParser()
        ]
    }

    mutating func addParser(for elementType: String, parser: BaseCardElementParser) throws {
        guard !knownElements.contains(elementType) else {
            throw AdaptiveCardParseError.unsupportedParserOverride
        }
        cardElementParsers[elementType] = parser
    }

    mutating func removeParser(for elementType: String) throws {
        guard !knownElements.contains(elementType) else {
            throw AdaptiveCardParseError.unsupportedParserOverride
        }
        cardElementParsers.removeValue(forKey: elementType)
    }

    func getParser(for elementType: String) -> BaseCardElementParser? {
        guard let parser = cardElementParsers[elementType] else { return nil }
        return BaseCardElementParserWrapper(parser: parser)
    }
}

/// Error types for parsing Adaptive Cards.
enum AdaptiveCardParseError: Error {
    case invalidJson
    case renderFailed
    case requiredPropertyMissing
    case invalidPropertyValue
    case unsupportedParserOverride
    case idCollision
    case invalidType
    case customError
    case serializationFailed
}
