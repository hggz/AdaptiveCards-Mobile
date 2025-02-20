import Foundation

enum DelimiterType {
    case initType, alphanumeric, punctuation, escape, whiteSpace, underscore, asterisk
}

enum MarkDownBlockType {
    case containerBlock, unorderedList, orderedList
}

class MarkDownHtmlGenerator {
    var numberOfUnusedDelimiters: Int = 0
    var directionType: Int = 0  // 0 for left, 1 for right
    var type: DelimiterType = .initType
    var tags: [String] = []
    
    var token: String
    var isHead: Bool = false
    var isTail: Bool = false
    
    init(token: String = "") {
        self.token = token
    }
    
    func makeItHead() {
        isHead = true
    }
    
    func makeItTail() {
        isTail = true
    }
    
    func isNewLine() -> Bool {
        return false
    }
    
    func generateHtmlString() -> String {
        fatalError("Must override in subclass")
    }
    
    func getBlockType() -> MarkDownBlockType {
        return .containerBlock
    }
}

// - MarkDownStringHtmlGenerator
class MarkDownStringHtmlGenerator: MarkDownHtmlGenerator {
    override func generateHtmlString() -> String {
        var result = token
        if isHead { result = "<p>" + result }
        if isTail { result += "</p>" }
        return result
    }
}

// - MarkDownNewLineHtmlGenerator
class MarkDownNewLineHtmlGenerator: MarkDownStringHtmlGenerator {
    override func isNewLine() -> Bool {
        return true
    }
}

// - MarkDownEmphasisHtmlGenerator
class MarkDownEmphasisHtmlGenerator: MarkDownHtmlGenerator {
    
    // Remove duplicate property declarations; we use the ones inherited from MarkDownHtmlGenerator.
    
    init(token: String, sizeOfEmphasisDelimiterRun: Int, type: DelimiterType, tags: [String] = []) {
        super.init(token: token)
        self.numberOfUnusedDelimiters = sizeOfEmphasisDelimiterRun
        self.type = type
        self.tags = tags
    }
    
    func isRightEmphasis() -> Bool { return false }
    func isLeftEmphasis() -> Bool { return false }
    func isLeftAndRightEmphasis() -> Bool { return false }
    
    func pushItalicTag() {
        tags.append("<em>")
    }
    
    func pushBoldTag() {
        tags.append("<strong>")
    }
    
    func isMatch(_ emphasisToken: MarkDownEmphasisHtmlGenerator) -> Bool {
        return self.type == emphasisToken.type &&
          !((self.isLeftAndRightEmphasis() || emphasisToken.isLeftAndRightEmphasis()) &&
            ((self.numberOfUnusedDelimiters + emphasisToken.numberOfUnusedDelimiters) % 3 == 0))
    }
    
    func adjustEmphasisCounts(leftOver: Int, rightToken: MarkDownEmphasisHtmlGenerator) -> Int {
        let delimiterCount: Int
        if leftOver >= 0 {
            delimiterCount = self.numberOfUnusedDelimiters - leftOver
            self.numberOfUnusedDelimiters = leftOver
            rightToken.numberOfUnusedDelimiters = 0
        } else {
            delimiterCount = self.numberOfUnusedDelimiters
            rightToken.numberOfUnusedDelimiters = -leftOver
            self.numberOfUnusedDelimiters = 0
        }
        return delimiterCount
    }
    
    func generateTags(with token: MarkDownEmphasisHtmlGenerator) -> Bool {
        let leftOver = self.numberOfUnusedDelimiters - token.numberOfUnusedDelimiters
        let delimiterCount = adjustEmphasisCounts(leftOver: leftOver, rightToken: token)
        let hasHtmlTags = delimiterCount > 0
        
        if delimiterCount % 2 != 0 {
            self.pushItalicTag()
            token.pushItalicTag()
        }
        
        for _ in 0..<(delimiterCount / 2) {
            self.pushBoldTag()
            token.pushBoldTag()
        }
        
        return hasHtmlTags
    }
    
    func changeDirectionToLeft() {
        self.directionType = -1
    }
    
    func isSameType(_ other: MarkDownEmphasisHtmlGenerator) -> Bool {
        return self.type == other.type
    }
    
    func isDone() -> Bool {
        return self.numberOfUnusedDelimiters == 0
    }
}

// - MarkDownLeftEmphasisHtmlGenerator
class MarkDownLeftEmphasisHtmlGenerator: MarkDownEmphasisHtmlGenerator {
    override func isLeftEmphasis() -> Bool { return true }
    
    override func generateHtmlString() -> String {
        var html = ""
        if isHead { html += "<p>" }
        if numberOfUnusedDelimiters == 0 {
            html += tags.joined()
        } else {
            html += token + tags.joined()
        }
        if isTail { html += "</p>" }
        return html
    }
}

class MarkDownLeftAndRightEmphasisHtmlGenerator: MarkDownRightEmphasisHtmlGenerator {
    override func isLeftAndRightEmphasis() -> Bool { return true }
    
    override func pushItalicTag() {
        tags.append(directionType == 0 ? "<em>" : "</em>")
    }
    
    override func pushBoldTag() {
        tags.append(directionType == 0 ? "<strong>" : "</strong>")
    }
}

// - MarkDownRightEmphasisHtmlGenerator
class MarkDownRightEmphasisHtmlGenerator: MarkDownEmphasisHtmlGenerator {
    override func isRightEmphasis() -> Bool { return directionType == 1 }
    override func isLeftEmphasis() -> Bool { return directionType == 0 }
    
    override func pushItalicTag() {
        tags.append("</em>")
    }
    
    override func pushBoldTag() {
        tags.append("</strong>")
    }
    
    override func generateHtmlString() -> String {
        var html = ""
        if isHead { html += "<p>" }
        // If fully paired, don’t output the original delimiter characters.
        if numberOfUnusedDelimiters == 0 {
            html += tags.joined()
        } else {
            // Otherwise, output any leftover (if not fully paired) along with tags.
            html += tags.joined() + token
        }
        if isTail { html += "</p>" }
        return html
    }
}

// - MarkDownListHtmlGenerator
class MarkDownListHtmlGenerator: MarkDownStringHtmlGenerator {
    override func generateHtmlString() -> String {
        var result = token
        if isHead { result = "<ul>" + result }
        if isTail { result += "</ul>" }
        return result
    }
    
    override func getBlockType() -> MarkDownBlockType {
        return .unorderedList
    }
}

// - MarkDownOrderedListHtmlGenerator
class MarkDownOrderedListHtmlGenerator: MarkDownStringHtmlGenerator {
    var numberString: String
    
    init(token: String, numberString: String) {
        self.numberString = numberString
        super.init(token: token)
    }
    
    override func generateHtmlString() -> String {
        var result = token
        if isHead { result = "<ol start=\"\(numberString)\">" + result }
        if isTail { result += "</ol>" }
        return result
    }
    
    override func getBlockType() -> MarkDownBlockType {
        return .orderedList
    }
}

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
                // Compute the preceding character once and keep it in scope.
                var preceding: Character? = currentToken.last
                if preceding == nil {
                    preceding = parsedResult.lastPlainTextCharacter()
                }
                
                if ch == "_" {
                    // Create a temporary copy to peek at the character immediately following the underscore.
                    var tempStream = stream
                    _ = tempStream.next() // consume underscore in the copy
                    if let after = tempStream.peek() {
                        // (1) If the underscore is in an intra-word context (preceded and followed by a letter/number), output it literally.
                        if let pre = preceding, (pre.isLetter || pre.isNumber), (after.isLetter || after.isNumber) {
                            currentToken.append(stream.next()!)
                            continue
                        }
                        // (2) If the preceding character is alphanumeric and the character after is punctuation, output it literally.
                        if let pre = preceding, (pre.isLetter || pre.isNumber), isPunctuation(after) {
                            currentToken.append(stream.next()!)
                            continue
                        }
                        // (3) If the character following the underscore is whitespace, output it literally.
                        if after.isWhitespace {
                            currentToken.append(stream.next()!)
                            continue
                        }
                    }
                    // If there is no character after, fall through so that the underscore is processed as a delimiter run.
                }
                
                // For asterisks, use your existing literal check.
                if ch == "*" {
                    if let last = currentToken.last, last.isLetter || last.isNumber {
                        var tempStream = stream
                        _ = tempStream.next() // consume one asterisk in copy
                        if let after = tempStream.peek(), isPunctuation(after) {
                            currentToken.append(stream.next()!)
                            continue
                        }
                    }
                }
                
                // Otherwise, consume the delimiter run normally.
                let (delimStr, count) = consumeDelimiterRun(stream: &stream, delimiter: ch)
                flushToken()
                
                // Look ahead to decide the run’s direction.
                let nextChar = stream.peek()
                let delimiterIsClosing = (nextChar?.isWhitespace ?? true) || (nextChar.map { isPunctuation($0) } ?? false)
                var direction = delimiterIsClosing ? 1 : 0  // default determination
                
                if ch == "*" {
                    // For asterisks: if the preceding character is whitespace, output literally.
                    if let pre = preceding, pre.isWhitespace {
                        currentToken.append(delimStr)
                        continue
                    }
                    let hasUnmatchedOpening = parsedResult.emphasisLookUpTable.contains { $0.type == .asterisk && $0.directionType == 0 }
                    if hasUnmatchedOpening {
                        direction = 1
                    }
                }
                if ch == "_" {
                    // For underscores, if there is a following character, and the preceding character is not alphanumeric, force opening.
                    if let nextChar = nextChar {
                        if let pre = preceding, !(pre.isLetter || pre.isNumber) {
                            direction = 0
                        } else if preceding == nil {
                            direction = 0
                        }
                    }
                }
                
                var emphasisToken = MarkDownLeftAndRightEmphasisHtmlGenerator(
                    token: delimStr,
                    sizeOfEmphasisDelimiterRun: count,
                    type: (ch == "*") ? .asterisk : .underscore
                )
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

class MarkDownParsedResult {
    private var codeGenTokens: [MarkDownHtmlGenerator] = []
    public var emphasisLookUpTable: [MarkDownEmphasisHtmlGenerator] = []
    private var isHTMLTagsAdded: Bool = false
    private var isCaptured: Bool = false

    init() {}

    func translate() {
        matchLeftAndRightEmphasises()
    }

    func addBlockTags() {
        codeGenTokens.first?.makeItHead()
        codeGenTokens.last?.makeItTail()
    }

    private func markTags(_ x: MarkDownHtmlGenerator) {
        if let lastToken = codeGenTokens.last, lastToken.getBlockType() != x.getBlockType() {
            if lastToken.isNewLine() {
                codeGenTokens.removeLast()
            }

            if !codeGenTokens.isEmpty {
                codeGenTokens.last?.makeItTail()
            }
            x.makeItHead()
        }
    }

    func appendParseResult(_ other: MarkDownParsedResult) {
        if !codeGenTokens.isEmpty, !other.codeGenTokens.isEmpty {
            markTags(other.codeGenTokens.first!)
        }
        codeGenTokens.append(contentsOf: other.codeGenTokens)
        emphasisLookUpTable.append(contentsOf: other.emphasisLookUpTable)
        isHTMLTagsAdded = isHTMLTagsAdded || other.hasHtmlTags()
        isCaptured = other.isCaptured
    }

    func appendToTokens(_ token: MarkDownHtmlGenerator) {
        if !codeGenTokens.isEmpty {
            markTags(token)
        }
        codeGenTokens.append(token)
    }

    func appendToLookUpTable(_ token: MarkDownEmphasisHtmlGenerator) {
        emphasisLookUpTable.append(token)
    }

    func popFront() {
        if !codeGenTokens.isEmpty {
            codeGenTokens.removeFirst()
        }
    }

    func popBack() {
        if !codeGenTokens.isEmpty {
            codeGenTokens.removeLast()
        }
    }

    func clear() {
        codeGenTokens.removeAll()
        emphasisLookUpTable.removeAll()
    }

    func addNewTokenToParsedResult(_ ch: Character) {
        let token = MarkDownStringHtmlGenerator(token: String(ch))
        appendToTokens(token)
    }

    func addNewTokenToParsedResult(_ word: String) {
        let token = MarkDownStringHtmlGenerator(token: word)
        appendToTokens(token)
    }

    func addNewLineTokenToParsedResult(_ ch: Character) {
        let token = MarkDownNewLineHtmlGenerator(token: String(ch))
        appendToTokens(token)
    }

    func generateHtmlString() -> String {
        return codeGenTokens.map { $0.generateHtmlString() }.joined()
    }

    private func matchLeftAndRightEmphasises() {
        var leftEmphasisToExplore: [MarkDownEmphasisHtmlGenerator] = []
        var currentEmphasisIndex = 0

        while currentEmphasisIndex < emphasisLookUpTable.count {
            let currentEmphasis = emphasisLookUpTable[currentEmphasisIndex]

            if currentEmphasis.isLeftEmphasis() || (currentEmphasis.isLeftAndRightEmphasis() && leftEmphasisToExplore.isEmpty) {
                if currentEmphasis.isLeftAndRightEmphasis(), currentEmphasis.isRightEmphasis() {
                    currentEmphasis.changeDirectionToLeft()
                }
                leftEmphasisToExplore.append(currentEmphasis)
                currentEmphasisIndex += 1
            } else if !leftEmphasisToExplore.isEmpty {
                let currentLeftEmphasis = leftEmphasisToExplore.removeLast()

                if !currentLeftEmphasis.isMatch(currentEmphasis) {
                    var isFound = false
                    var storedLeftTokens: [MarkDownEmphasisHtmlGenerator] = []

                    while !leftEmphasisToExplore.isEmpty && !isFound {
                        let leftToken = leftEmphasisToExplore.removeLast()
                        if leftToken.isMatch(currentEmphasis) {
                            isFound = true
                            leftEmphasisToExplore.append(leftToken)
                        } else {
                            storedLeftTokens.append(leftToken)
                        }
                    }

                    if !isFound, let lastLeft = leftEmphasisToExplore.last, lastLeft.isSameType(currentEmphasis) {
                        currentEmphasis.changeDirectionToLeft()
                    } else {
                        storedLeftTokens.reversed().forEach { leftEmphasisToExplore.append($0) }
                        currentEmphasisIndex += 1
                        continue
                    }
                }

                // Pair the tokens: generate tags and force the delimiter counts to zero.
                isHTMLTagsAdded = currentLeftEmphasis.generateTags(with: currentEmphasis) || isHTMLTagsAdded
                currentLeftEmphasis.numberOfUnusedDelimiters = 0
                currentEmphasis.numberOfUnusedDelimiters = 0

                if currentEmphasis.isDone() {
                    currentEmphasisIndex += 1
                }

                if currentLeftEmphasis.isDone() {
                    _ = leftEmphasisToExplore.popLast()
                }
            } else {
                currentEmphasisIndex += 1
            }
        }
    }

    func hasHtmlTags() -> Bool {
        return isHTMLTagsAdded
    }

    func foundHtmlTags() {
        isHTMLTagsAdded = true
    }

    func getIsCaptured() -> Bool {
        return isCaptured
    }

    func setIsCaptured(_ val: Bool) {
        isCaptured = val
    }
}

extension MarkDownParsedResult {
    func lastPlainTextCharacter() -> Character? {
        for token in codeGenTokens.reversed() {
            if let stringToken = token as? MarkDownStringHtmlGenerator, !stringToken.token.isEmpty {
                return stringToken.token.last
            }
        }
        return nil
    }
}

class MarkDownParser {
    private let text: String
    private var parsedResult = MarkDownParsedResult()
    private var hasHTMLTag = false
    private var isEscaped = false

    init(_ text: String) {
        self.text = text
    }

    /// Transforms Markdown string to HTML
    func transformToHtml() -> String { // ✅ Made mutating
        guard !text.isEmpty else {
            return "<p></p>"
        }

        // Begin parsing HTML blocks
        parseBlock()

        // Process further what is parsed before outputting HTML string
        parsedResult.translate()

        // Add block tags such as <p> <ul>
        parsedResult.addBlockTags()

        hasHTMLTag = parsedResult.hasHtmlTags()
        return parsedResult.generateHtmlString()
    }

    /// Returns the raw text
    func getRawText() -> String {
        return text
    }

    /// Checks if the text contains HTML tags
    func hasHtmlTags() -> Bool {
        return hasHTMLTag
    }

    /// Checks if the text is escaped
    func isEscapedText() -> Bool {
        return isEscaped
    }

    /// Parses Markdown blocks
    private func parseBlock() {
        let escapedText = escapeText()
        var stream = StringIterator(escapedText)
        var parser = EmphasisParser()
        parser.parseBlock(stream: &stream)
        parsedResult.appendParseResult(parser.getParsedResult())
    }

    /// Escapes special HTML characters in the Markdown text
    private func escapeText() -> String {
        var escaped = ""
        var nonEscapedCounts = 0

        for char in text {
            switch char {
            case "<":
                escaped.append("&lt;")
            case ">":
                escaped.append("&gt;")
            case "\"":
                escaped.append("&quot;")
            case "&":
                escaped.append("&amp;")
            default:
                escaped.append(char)
                nonEscapedCounts += 1
            }
        }

        isEscaped = (nonEscapedCounts != text.count)
        return escaped
    }
}
