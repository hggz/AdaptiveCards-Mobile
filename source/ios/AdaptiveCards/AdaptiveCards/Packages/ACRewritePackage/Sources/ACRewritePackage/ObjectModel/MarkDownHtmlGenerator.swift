import Foundation

// MARK: - Types and Enums

enum DelimiterType {
    case initType, alphanumeric, punctuation, escape, whiteSpace, underscore, asterisk
}

enum MarkDownBlockType {
    case containerBlock, unorderedList, orderedList
}

// MARK: - HTML Generator Classes

class MarkDownHtmlGenerator {
    var token: String
    var isHead: Bool = false
    var isTail: Bool = false
    var tags: [String] = []
    
    init(token: String) {
        self.token = token
    }
    
    func makeItHead() {
        isHead = true
    }
    
    func makeItTail() {
        isTail = true
    }
    
    func generateHtmlString() -> String {
        fatalError("Must override in subclass")
    }
    
    func getBlockType() -> MarkDownBlockType {
        return .containerBlock
    }
}

class MarkDownStringHtmlGenerator: MarkDownHtmlGenerator {
    override func generateHtmlString() -> String {
        var result = token
        if isHead { result = "<p>" + result }
        if isTail { result += "</p>" }
        return result
    }
}

class MarkDownNewLineHtmlGenerator: MarkDownStringHtmlGenerator {
    override func generateHtmlString() -> String {
        return super.generateHtmlString()
    }
}

class MarkDownEmphasisHtmlGenerator: MarkDownHtmlGenerator {
    var numberOfUnusedDelimiters: Int
    var directionType: Int = 1  // 0 = left; 1 = right
    var type: DelimiterType
    
    init(token: String, sizeOfEmphasisDelimiterRun: Int, type: DelimiterType, tags: [String] = []) {
        self.numberOfUnusedDelimiters = sizeOfEmphasisDelimiterRun
        self.type = type
        super.init(token: token)
        self.tags = tags
    }
    
    func isRightEmphasis() -> Bool { return directionType == 1 }
    func isLeftEmphasis() -> Bool { return directionType == 0 }
    func isLeftAndRightEmphasis() -> Bool { return false }
    
    func pushItalicTag() {
        tags.append("<em>")
    }
    
    func pushBoldTag() {
        tags.append("<strong>")
    }
    
    func isMatch(_ emphasisToken: MarkDownEmphasisHtmlGenerator) -> Bool {
        if self.type == emphasisToken.type {
            if (self.isLeftAndRightEmphasis() || emphasisToken.isLeftAndRightEmphasis()) &&
               ((self.numberOfUnusedDelimiters + emphasisToken.numberOfUnusedDelimiters) % 3 == 0) {
                return false
            }
            return true
        }
        return false
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
        self.directionType = 0
    }
    
    func isSameType(_ other: MarkDownEmphasisHtmlGenerator) -> Bool {
        return self.type == other.type
    }
    
    func isDone() -> Bool {
        return self.numberOfUnusedDelimiters == 0
    }
    
    override func generateHtmlString() -> String {
        var html = ""
        if isHead { html += "<p>" }
        html += tags.joined()
        if numberOfUnusedDelimiters > 0 {
            html += String(token.suffix(numberOfUnusedDelimiters))
        }
        if isTail { html += "</p>" }
        return html
    }
}

class MarkDownLeftEmphasisHtmlGenerator: MarkDownEmphasisHtmlGenerator {
    override func isLeftEmphasis() -> Bool { return true }
    
    override func generateHtmlString() -> String {
        var html = ""
        if isHead { html += "<p>" }
        if numberOfUnusedDelimiters > 0 {
            html += String(token.suffix(numberOfUnusedDelimiters))
        }
        html += tags.reversed().joined()
        if isTail { html += "</p>" }
        return html
    }
}

class MarkDownRightEmphasisHtmlGenerator: MarkDownEmphasisHtmlGenerator {
    override func isRightEmphasis() -> Bool { return directionType == 1 }
    override func isLeftEmphasis() -> Bool { return directionType == 0 }
    
    override func generateHtmlString() -> String {
        var html = ""
        if isHead { html += "<p>" }
        html += tags.joined()
        if numberOfUnusedDelimiters > 0 {
            html += String(token.suffix(numberOfUnusedDelimiters))
        }
        if isTail { html += "</p>" }
        return html
    }
    
    override func pushItalicTag() {
        tags.append("</em>")
    }
    
    override func pushBoldTag() {
        tags.append("</strong>")
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

class MarkDownAnchorHtmlGenerator: MarkDownHtmlGenerator {
    var href: String
    var linkText: String
    
    init(linkText: String, href: String) {
        self.linkText = linkText
        self.href = href
        super.init(token: "")
    }
    
    override func generateHtmlString() -> String {
        var html = ""
        if isHead { html += "<p>" }
        html += "<a href=\"\(href)\">\(linkText)</a>"
        if isTail { html += "</p>" }
        return html
    }
}

// MARK: - Parsed Result

class MarkDownParsedResult {
    var codeGenTokens: [MarkDownHtmlGenerator] = []
    var emphasisLookUpTable: [MarkDownEmphasisHtmlGenerator] = []
    private var isHTMLTagsAdded: Bool = false
    private var isCaptured: Bool = false
    
    func translate() {
        matchLeftAndRightEmphasises()
    }
    
    func addBlockTags() {
        codeGenTokens.first?.makeItHead()
        codeGenTokens.last?.makeItTail()
    }
    
    private func markTags(_ x: MarkDownHtmlGenerator) {
        if let lastToken = codeGenTokens.last, lastToken.getBlockType() != x.getBlockType() {
            if lastToken is MarkDownNewLineHtmlGenerator {
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
            
            if currentEmphasis.isLeftEmphasis() ||
               (currentEmphasis.isLeftAndRightEmphasis() && leftEmphasisToExplore.isEmpty) {
                if currentEmphasis.isLeftAndRightEmphasis() && currentEmphasis.isRightEmphasis() {
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
                        for token in storedLeftTokens.reversed() {
                            leftEmphasisToExplore.append(token)
                        }
                        currentEmphasisIndex += 1
                        continue
                    }
                }
                
                isHTMLTagsAdded = currentLeftEmphasis.generateTags(with: currentEmphasis) || isHTMLTagsAdded
                currentLeftEmphasis.numberOfUnusedDelimiters = 0
                currentEmphasis.numberOfUnusedDelimiters = 0
                
                if currentEmphasis.isDone() {
                    currentEmphasisIndex += 1
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
    
    func lastPlainTextCharacter() -> Character? {
        for token in codeGenTokens.reversed() {
            if let stringToken = token as? MarkDownStringHtmlGenerator, !stringToken.token.isEmpty {
                return stringToken.token.last
            }
        }
        return nil
    }
}

// MARK: - String Iterator

struct StringIterator {
    let text: [Character]
    var index: Int = 0
    
    init(_ text: String) {
        self.text = Array(text)
    }
    
    mutating func next() -> Character? {
        guard index < text.count else { return nil }
        let ch = text[index]
        index += 1
        return ch
    }
    
    func peek() -> Character? {
        return index < text.count ? text[index] : nil
    }
    
    mutating func putBack() {
        if index > 0 { index -= 1 }
    }
}

// MARK: - Block Parsing Protocol and Implementations

protocol MarkDownBlockParser {
    var parsedResult: MarkDownParsedResult { get set }
    func match(stream: inout StringIterator)
}

extension MarkDownBlockParser {
    mutating func parseBlock(stream: inout StringIterator) {
        guard let peekChar = stream.peek() else { return }
        switch peekChar {
        case "[":
            let linkParser = LinkParser()
            linkParser.match(stream: &stream)
            parsedResult.appendParseResult(linkParser.parsedResult)
        case "]", ")":
            if let ch = stream.next() {
                parsedResult.addNewTokenToParsedResult(ch)
            }
        case "\n", "\r":
            if let ch = stream.next() {
                parsedResult.addNewLineTokenToParsedResult(ch)
            }
        case "-", "+", "*":
            let listParser = ListParser()
            listParser.match(stream: &stream)
            parsedResult.appendParseResult(listParser.parsedResult)
        case "0"..."9":
            let orderedListParser = OrderedListParser()
            orderedListParser.match(stream: &stream)
            parsedResult.appendParseResult(orderedListParser.parsedResult)
        default:
            var emphasisParser = EmphasisParser()
            emphasisParser.match(stream: &stream)
            parsedResult.appendParseResult(emphasisParser.getParsedResult())
        }
    }
}

class EmphasisParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    private var currentToken: String = ""
    
    func match(stream: inout StringIterator) {
        parseBlock(stream: &stream)
    }
    
    func parseBlock(stream: inout StringIterator) {
        while let ch = stream.peek() {
            if isMarkDownDelimiter(ch) {
                let preceding = currentToken.last ?? parsedResult.lastPlainTextCharacter()
                if ch == "_" {
                    var tempStream = stream
                    _ = tempStream.next()
                    if let after = tempStream.peek() {
                        if let pre = preceding, (pre.isLetter || pre.isNumber), (after.isLetter || after.isNumber) {
                            currentToken.append(stream.next()!)
                            continue
                        }
                        if let pre = preceding, (pre.isLetter || pre.isNumber), isPunctuation(after) {
                            currentToken.append(stream.next()!)
                            continue
                        }
                        if after.isWhitespace {
                            currentToken.append(stream.next()!)
                            continue
                        }
                    }
                }
                if ch == "*" {
                    if let last = currentToken.last, last.isLetter || last.isNumber {
                        var tempStream = stream
                        _ = tempStream.next()
                        if let after = tempStream.peek(), isPunctuation(after) {
                            currentToken.append(stream.next()!)
                            continue
                        }
                    }
                }
                let (delimStr, count) = consumeDelimiterRun(stream: &stream, delimiter: ch)
                flushToken()
                let nextChar = stream.peek()
                var direction: Int = 0
                if preceding == nil {
                    direction = 0
                } else {
                    let pre = preceding!
                    let leftFlanking = (nextChar != nil && !nextChar!.isWhitespace) &&
                        (pre.isWhitespace || isPunctuation(pre))
                    let rightFlanking = (!pre.isWhitespace) &&
                        ((nextChar == nil) || nextChar!.isWhitespace || (nextChar != nil && isPunctuation(nextChar!)))
                    if leftFlanking && rightFlanking {
                        let hasUnmatchedOpening = parsedResult.emphasisLookUpTable.contains { $0.type == (ch == "*" ? .asterisk : .underscore) && $0.directionType == 0 }
                        direction = hasUnmatchedOpening ? 1 : 0
                    } else if leftFlanking {
                        direction = 0
                    } else if rightFlanking {
                        direction = 1
                    } else {
                        direction = 0
                    }
                }
                if ch == "*" {
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
                    if let nextChar = nextChar {
                        if let pre = preceding, !(pre.isLetter || pre.isNumber) {
                            direction = 0
                        } else if preceding == nil {
                            direction = 0
                        }
                    }
                }
                var emphasisToken = MarkDownLeftAndRightEmphasisHtmlGenerator(token: delimStr, sizeOfEmphasisDelimiterRun: count, type: (ch == "*" ? .asterisk : .underscore))
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
    
    private func flushToken() {
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
    
    private func consumeDelimiterRun(stream: inout StringIterator, delimiter: Character) -> (String, Int) {
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

class LinkParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
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
}

class ListParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
        // Check validity: marker must be followed by a space.
        guard let marker = stream.next() else { return }
        if stream.peek() != " " {
            // Not a valid list marker: put marker back and use emphasis parser.
            stream.putBack()
            var emphasisParser = EmphasisParser()
            emphasisParser.match(stream: &stream)
            parsedResult.appendParseResult(emphasisParser.getParsedResult())
            return
        }
        // Consume the space.
        _ = stream.next()
        
        var items: [String] = []
        repeat {
            var listText = ""
            while let c = stream.peek(), c != "\n", c != "\r" {
                listText.append(stream.next()!)
            }
            items.append("<li>" + listText + "</li>")
            while let c = stream.peek(), c == "\n" || c == "\r" {
                _ = stream.next()
            }
        } while stream.peek() == marker

        let combined = items.joined()
        let listToken = MarkDownListHtmlGenerator(token: combined)
        listToken.makeItHead()
        listToken.makeItTail()
        parsedResult.appendToTokens(listToken)
    }
}

class OrderedListParser: MarkDownBlockParser {
    var parsedResult = MarkDownParsedResult()
    
    func match(stream: inout StringIterator) {
        // Save current index to roll back if not valid.
        let startIndex = stream.index
        var numberString = ""
        while let c = stream.peek(), c.isNumber {
            numberString.append(stream.next()!)
        }
        guard let dot = stream.peek(), dot == "." else {
            // Not a valid ordered list marker; roll back.
            stream.index = startIndex
            var emphasisParser = EmphasisParser()
            emphasisParser.match(stream: &stream)
            parsedResult.appendParseResult(emphasisParser.getParsedResult())
            return
        }
        _ = stream.next() // consume '.'
        if let space = stream.peek(), space == " " {
            _ = stream.next() // consume space
        }
        let startNumber = numberString
        var items: [String] = []
        repeat {
            var listText = ""
            while let c = stream.peek(), c != "\n", c != "\r" {
                listText.append(stream.next()!)
            }
            items.append("<li>" + listText + "</li>")
            while let c = stream.peek(), c == "\n" || c == "\r" {
                _ = stream.next()
            }
            // Check for another list item marker.
            var tempIndex = stream.index
            var nextNumber = ""
            while let c = stream.peek(), c.isNumber {
                nextNumber.append(stream.next()!)
            }
            if let dot = stream.peek(), dot == "." {
                // valid next item marker; restore stream and continue.
                stream.index = tempIndex
            } else {
                // no more valid markers.
                stream.index = tempIndex
                break
            }
        } while true
        
        let combined = items.joined()
        let orderedToken = MarkDownOrderedListHtmlGenerator(token: combined, numberString: startNumber)
        orderedToken.makeItHead()
        orderedToken.makeItTail()
        parsedResult.appendToTokens(orderedToken)
    }
}

// MARK: - Main Parser

class MarkDownParser {
    private let text: String
    private var parsedResult = MarkDownParsedResult()
    private var hasHTMLTag: Bool = false
    private var isEscaped: Bool = false
    
    init(_ text: String) {
        self.text = text
    }
    
    /// Transforms Markdown string to HTML.
    func transformToHtml() -> String {
        if text.isEmpty {
            return "<p></p>"
        }
        parseBlock()
        parsedResult.translate()
        parsedResult.addBlockTags()
        hasHTMLTag = parsedResult.hasHtmlTags()
        return parsedResult.generateHtmlString()
    }
    
    func getRawText() -> String {
        return text
    }
    
    func hasHtmlTags() -> Bool {
        return hasHTMLTag
    }
    
    func isEscapedText() -> Bool {
        return isEscaped
    }
    
    private func parseBlock() {
        let escapedText = escapeText()
        var stream = StringIterator(escapedText)
        // We'll track if we are at the beginning of a new block.
        var atStartOfLine = true
        
        while let ch = stream.peek() {
            if ch == "\n" || ch == "\r" {
                // Always output newline tokens.
                if let newline = stream.next() {
                    parsedResult.addNewLineTokenToParsedResult(newline)
                }
                atStartOfLine = true
            } else if atStartOfLine {
                // Look ahead to decide if this is a list marker or an ordered list.
                if ch == "-" || ch == "+" || ch == "*" {
                    var temp = stream
                    let marker = temp.next()!
                    if let next = temp.peek(), next == " " {
                        let listParser = ListParser()
                        listParser.match(stream: &stream)
                        parsedResult.appendParseResult(listParser.parsedResult)
                        atStartOfLine = true
                        continue
                    }
                } else if ch.isNumber {
                    var temp = stream
                    var numberString = ""
                    while let c = temp.peek(), c.isNumber {
                        numberString.append(temp.next()!)
                    }
                    if let next = temp.peek(), next == "." {
                        let orderedListParser = OrderedListParser()
                        orderedListParser.match(stream: &stream)
                        parsedResult.appendParseResult(orderedListParser.parsedResult)
                        atStartOfLine = true
                        continue
                    }
                }
                // Otherwise, treat as regular text/emphasis.
                var emphasisParser = EmphasisParser()
                emphasisParser.match(stream: &stream)
                parsedResult.appendParseResult(emphasisParser.getParsedResult())
                atStartOfLine = false
            } else {
                // Not at start-of-line; use emphasis parsing.
                var emphasisParser = EmphasisParser()
                emphasisParser.match(stream: &stream)
                parsedResult.appendParseResult(emphasisParser.getParsedResult())
                // If the generated token ends with a newline, we are at start-of-line.
                if let lastToken = parsedResult.codeGenTokens.last?.generateHtmlString().last,
                   lastToken == "\n" || lastToken == "\r" {
                    atStartOfLine = true
                } else {
                    atStartOfLine = false
                }
            }
        }
    }
    
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
