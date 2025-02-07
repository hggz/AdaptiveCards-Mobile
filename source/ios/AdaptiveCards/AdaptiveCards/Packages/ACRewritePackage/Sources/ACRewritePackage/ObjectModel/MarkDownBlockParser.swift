import Foundation

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
        parsedResult.appendParseResult(emphasisParser.parsedResult)
    }
}

struct EmphasisParser: MarkDownBlockParser {
    enum EmphasisState {
        case text, emphasis, captured
    }
    
    var parsedResult = MarkDownParsedResult()
    private var currentState: EmphasisState = .text
    private var currentToken = ""
    
    mutating func match(stream: inout StringIterator) {
        while currentState != .captured {
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
        default:
            return .captured
        }
    }
    
    private mutating func matchText(stream: inout StringIterator, char: Character) -> EmphasisState {
        if isEmphasisToken(char) {
            flushToken()
            return .captured
        }
        
        if isMarkDownDelimiter(char) {
            flushToken()
            currentToken.append(stream.next()!)
            return .emphasis
        }
        
        currentToken.append(stream.next()!)
        return .text
    }
    
    private mutating func matchEmphasis(stream: inout StringIterator, char: Character) -> EmphasisState {
        if isEmphasisToken(char) {
            flushToken()
            return .captured
        }
        
        if isMarkDownDelimiter(char) {
            currentToken.append(stream.next()!)
        } else {
            captureEmphasisToken()
            currentToken.append(stream.next()!)
            return .text
        }
        
        return .emphasis
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
}

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
