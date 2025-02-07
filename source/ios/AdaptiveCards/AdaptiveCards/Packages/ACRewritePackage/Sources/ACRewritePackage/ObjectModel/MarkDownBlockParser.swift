import Foundation

// MARK: - Protocol & Extension

protocol MarkDownBlockParser {
    mutating func match(stream: inout StringIterator)
    mutating func parseBlock(stream: inout StringIterator)
    var parsedResult: MarkDownParsedResult { get }
}

extension MarkDownBlockParser {
    mutating func parseBlock(stream: inout StringIterator) {
        guard let peekChar = stream.peek() else { return }
        
        switch peekChar {
        case "[":
            var linkParser = LinkParser()
            linkParser.match(stream: &stream)
            parsedResult.appendParseResult(linkParser.parsedResult)
        case "]", ")":
            parsedResult.addNewTokenToParsedResult(peekChar)
            _ = stream.next()
        case "\n", "\r":
            parsedResult.addNewLineTokenToParsedResult(peekChar)
            _ = stream.next()
        case "-", "+", "*":
            var listParser = ListParser()
            listParser.match(stream: &stream)
            parsedResult.appendParseResult(listParser.parsedResult)
        case "0"..."9":
            var orderedListParser = OrderedListParser()
            orderedListParser.match(stream: &stream)
            parsedResult.appendParseResult(orderedListParser.parsedResult)
        default:
            parseTextAndEmphasis(stream: &stream)
        }
    }
    
    mutating func parseTextAndEmphasis(stream: inout StringIterator) {
        var emphasisParser = EmphasisParser()
        emphasisParser.match(stream: &stream)
        parsedResult.appendParseResult(emphasisParser.getParsedResult())
    }
}

// MARK: - Delimiter Type

// MARK: - Emphasis Parser

struct EmphasisParser: MarkDownBlockParser {
    enum EmphasisState {
        case text, emphasis, captured
    }
    
    var parsedResult = MarkDownParsedResult()
    private var currentState: EmphasisState = .text
    private var currentToken: String = ""
    
    // Additional internal state (stubs for now)
    private var delimiterCounts: Int = 0
    private var currentDelimiterType: DelimiterType = .initType
    private var lookBehind: DelimiterType = .initType
    
    mutating func match(stream: inout StringIterator) {
        while currentState != .captured, stream.peek() != nil {
            currentState = matchState(stream: &stream)
        }
    }
    
    private mutating func matchState(stream: inout StringIterator) -> EmphasisState {
        guard let currentChar = stream.peek() else { return .captured }
        switch currentState {
        case .text:
            return matchText(stream: &stream, char: currentChar)
        case .emphasis:
            return matchEmphasis(stream: &stream, char: currentChar)
        case .captured:
            return .captured
        }
    }
    
    private mutating func matchText(stream: inout StringIterator, char: Character) -> EmphasisState {
        // If an emphasis token is encountered, finish the token.
        if isEmphasisToken(char) {
            flushToken()
            return .captured
        }
        // If a markdown delimiter is encountered, switch state.
        if isMarkDownDelimiter(char) {
            flushToken()
            if let nextChar = stream.next() {
                currentToken.append(nextChar)
                updateCurrentEmphasisRunState(with: nextChar)
                return .emphasis
            }
            return .captured
        }
        // Otherwise, consume and append the character.
        if let nextChar = stream.next() {
            currentToken.append(nextChar)
        }
        return .text
    }
    
    private mutating func matchEmphasis(stream: inout StringIterator, char: Character) -> EmphasisState {
        // If an emphasis token is encountered, finish the token.
        if isEmphasisToken(char) {
            flushToken()
            return .captured
        }
        // If another markdown delimiter is encountered, update run state.
        if isMarkDownDelimiter(char) {
            if let nextChar = stream.next() {
                currentToken.append(nextChar)
                updateCurrentEmphasisRunState(with: nextChar)
            }
            return .emphasis
        } else {
            // Otherwise, capture the emphasis token and switch back to text state.
            captureEmphasisToken()
            if let nextChar = stream.next() {
                currentToken.append(nextChar)
            }
            return .text
        }
    }
    
    private mutating func flushToken() {
        if !currentToken.isEmpty {
            parsedResult.addNewTokenToParsedResult(currentToken)
            currentToken = ""
        }
    }
    
    private mutating func captureEmphasisToken() {
        parsedResult.addNewTokenToParsedResult("<em>" + currentToken + "</em>")
        currentToken = ""
    }
    
    private func isEmphasisToken(_ char: Character) -> Bool {
        return ["[", "]", ")", "\n", "\r"].contains(char)
    }
    
    private func isMarkDownDelimiter(_ char: Character) -> Bool {
        return char == "*" || char == "_"
    }
    
    private mutating func updateCurrentEmphasisRunState(with char: Character) {
        let delimiterType = Self.getDelimiterType(for: char)
        currentDelimiterType = delimiterType
        delimiterCounts += 1
    }
    
    static func getDelimiterType(for char: Character) -> DelimiterType {
        return (char == "*") ? .asterisk : .underscore
    }
    
    func getParsedResult() -> MarkDownParsedResult {
        return parsedResult
    }
}

// MARK: - String Iterator

struct StringIterator {
    private let text: [Character]
    private var index: Int = 0
    
    init(_ text: String) {
        self.text = Array(text)
    }
    
    mutating func next() -> Character? {
        guard index < text.count else { return nil }
        defer { index += 1 }
        return text[index]
    }
    
    func peek() -> Character? {
        return index < text.count ? text[index] : nil
    }
}

// MARK: - Stub Implementations for LinkParser, ListParser, OrderedListParser

// These stub implementations provide minimal behavior so that the overall parser compiles.
// You can expand these implementations to provide full Markdown parsing functionality later.

class LinkParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
        // Stub: simply consume the '[' if present
        if let ch = stream.next(), ch == "[" {
            parsedResult.addNewTokenToParsedResult(ch)
        }
        // (Full link parsing logic not implemented)
    }
    
    func parseBlock(stream: inout StringIterator) {
        match(stream: &stream)
    }
}

class ListParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
        // Stub: consume one list marker character and add it as a token
        if let ch = stream.next(), (ch == "-" || ch == "+" || ch == "*") {
            parsedResult.addNewTokenToParsedResult(ch)
        }
    }
    
    func parseBlock(stream: inout StringIterator) {
        match(stream: &stream)
    }
}

class OrderedListParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
        // Stub: consume digits until a '.' is encountered
        var numberString = ""
        while let ch = stream.peek(), ch.isNumber {
            if let digit = stream.next() {
                numberString.append(digit)
            }
        }
        if let ch = stream.next(), ch == "." {
            numberString.append(ch)
            parsedResult.addNewTokenToParsedResult(numberString)
        }
    }
    
    func parseBlock(stream: inout StringIterator) {
        match(stream: &stream)
    }
}
