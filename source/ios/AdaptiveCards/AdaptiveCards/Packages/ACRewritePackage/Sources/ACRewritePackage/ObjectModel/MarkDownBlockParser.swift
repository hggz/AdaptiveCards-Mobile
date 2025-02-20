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
            let linkParser = LinkParser()  // now using 'let' since LinkParser is a class
            linkParser.match(stream: &stream)
            parsedResult.appendParseResult(linkParser.parsedResult)
        case "]", ")":
            parsedResult.addNewTokenToParsedResult(peekChar)
            _ = stream.next()
        case "\n", "\r":
            parsedResult.addNewLineTokenToParsedResult(peekChar)
            _ = stream.next()
        case "-", "+", "*":
            let listParser = ListParser()
            listParser.match(stream: &stream)
            parsedResult.appendParseResult(listParser.parsedResult)
        case "0"..."9":
            let orderedListParser = OrderedListParser()
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
    var parsedResult = MarkDownParsedResult()
    private var currentToken: String = ""
    
    // MARK: - Conformance to MarkDownBlockParser
    mutating func match(stream: inout StringIterator) {
        self.parseBlock(stream: &stream)
    }
    
    mutating func parseBlock(stream: inout StringIterator) {
        while let ch = stream.peek() {
            if isMarkDownDelimiter(ch) {
                let (delimStr, count) = consumeDelimiterRun(stream: &stream, delimiter: ch)
                flushToken()
                // Look ahead: if the next char is whitespace or punctuation, consider this a closing delimiter.
                let nextChar = stream.peek()
                let delimiterIsClosing: Bool = {
                    if let nc = nextChar {
                        return nc.isWhitespace || isPunctuation(nc)
                    } else {
                        return true
                    }
                }()
                let direction = delimiterIsClosing ? 1 : 0  // 1 for right (closing), 0 for left (opening)
                var emphasisToken = MarkDownLeftAndRightEmphasisHtmlGenerator(
                    token: delimStr,
                    sizeOfEmphasisDelimiterRun: count,
                    type: (ch == "*") ? .asterisk : .underscore
                )
                // Set the direction; ambiguity is resolved since we now have a single definition.
                emphasisToken.directionType = direction
                parsedResult.appendToLookUpTable(emphasisToken)
                parsedResult.appendToTokens(emphasisToken)
            } else {
                if let nextChar = stream.next() {
                    currentToken.append(nextChar)
                }
            }
        }
        flushToken()
    }
    
    private mutating func flushToken() {
        if !currentToken.isEmpty {
            parsedResult.addNewTokenToParsedResult(currentToken)
            currentToken = ""
        }
    }
    
    private func isMarkDownDelimiter(_ char: Character) -> Bool {
        return char == "*" || char == "_"
    }
    
    private func isPunctuation(_ char: Character) -> Bool {
        return String(char).rangeOfCharacter(from: .punctuationCharacters) != nil
    }
    
    private mutating func consumeDelimiterRun(stream: inout StringIterator, delimiter: Character) -> (String, Int) {
        var delimStr = ""
        var count = 0
        while let ch = stream.peek(), ch == delimiter {
            _ = stream.next()
            delimStr.append(ch)
            count += 1
        }
        return (delimStr, count)
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

class ListParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
        guard let marker = stream.next(), marker == "-" || marker == "+" || marker == "*" else { return }
        if let ch = stream.peek(), ch == " " { _ = stream.next() }
        var listText = ""
        while let c = stream.peek(), c != "\n", c != "\r" {
            listText.append(stream.next()!)
        }
        let listToken = MarkDownListHtmlGenerator(token: "<li>" + listText + "</li>")
        listToken.makeItHead()
        listToken.makeItTail()
        parsedResult.appendToTokens(listToken)
    }
    
    func parseBlock(stream: inout StringIterator) {
        match(stream: &stream)
    }
}

class MarkDownAnchorHtmlGenerator: MarkDownHtmlGenerator {
    var href: String
    var linkText: String
    
    init(linkText: String, href: String) {
        self.linkText = linkText
        self.href = href
        super.init(token: "")
    }
    
    override func generateHtmlString() -> String {
        return "<a href=\"\(href)\">\(linkText)</a>"
    }
}

class OrderedListParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
        var numberString = ""
        while let ch = stream.peek(), ch.isNumber {
            numberString.append(stream.next()!)
        }
        if let dot = stream.next(), dot == "." {
            if let ch = stream.peek(), ch == " " { _ = stream.next() }
            var listText = ""
            while let c = stream.peek(), c != "\n", c != "\r" {
                listText.append(stream.next()!)
            }
            let orderedToken = MarkDownOrderedListHtmlGenerator(token: "<li>" + listText + "</li>", numberString: numberString)
            orderedToken.makeItHead()
            orderedToken.makeItTail()
            parsedResult.appendToTokens(orderedToken)
        } else {
            parsedResult.addNewTokenToParsedResult(numberString)
        }
    }
    
    func parseBlock(stream: inout StringIterator) {
        match(stream: &stream)
    }
}

class LinkParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
        // Assume stream.peek() is '['.
        guard let ch = stream.next(), ch == "[" else { return }
        var linkText = ""
        while let c = stream.peek(), c != "]" {
            linkText.append(stream.next()!)
        }
        _ = stream.next() // consume ']'
        guard let openParen = stream.next(), openParen == "(" else {
           parsedResult.addNewTokenToParsedResult("[" + linkText)
           return
        }
        var url = ""
        while let c = stream.peek(), c != ")" {
            url.append(stream.next()!)
        }
        _ = stream.next() // consume ')'
        
        let anchorToken = MarkDownAnchorHtmlGenerator(linkText: linkText, href: url)
        parsedResult.appendToTokens(anchorToken)
    }
    
    func parseBlock(stream: inout StringIterator) {
        match(stream: &stream)
    }
}

