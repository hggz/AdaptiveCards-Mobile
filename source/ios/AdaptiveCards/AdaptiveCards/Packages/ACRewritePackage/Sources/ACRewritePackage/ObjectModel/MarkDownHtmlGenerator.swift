import Foundation

enum DelimiterType {
    case asterisk
    case underscore
    case `init`
    case escape
    case whiteSpace
    case punctuation
    case alphanumeric
}

enum DirectionType {
    case left
    case right
}

class MarkDownStringHtmlGenerator: MarkDownHtmlGenerator {
    private var m_token: String
    private var m_isHead: Bool
    private var m_isTail: Bool
    
    init(token: String, isHead: Bool = false, isTail: Bool = false) {
        self.m_token = token
        self.m_isHead = isHead
        self.m_isTail = isTail
    }
    
    func generateHtmlString() -> String {
        if m_isHead {
            m_token = "<p>" + m_token
        }
        
        if m_isTail {
            return m_token + "</p>"
        }
        
        return m_token
    }
    
    // Protocol conformance
    func makeItHead() {
        m_isHead = true
    }
    
    func makeItTail() {
        m_isTail = true
    }
    
    func getBlockType() -> String {
        return "string" // or whatever block type is appropriate
    }
    
    func isNewLine() -> Bool {
        return false
    }
}

class MarkDownEmphasisHtmlGenerator: MarkDownHtmlGenerator {
    func isLeftEmphasis() -> Bool {
        // Implementation needed
        if type == .underscore {
            // For underscore, can't be left emphasis if preceded by alphanumeric
            return !hasAlphanumericPrefix()
        }
        // For asterisk, it can be left emphasis regardless
        return true
    }
        
    func isRightEmphasis() -> Bool {
        // Implementation needed
        if type == .underscore {
            // For underscore, can't be right emphasis if followed by alphanumeric
            return !hasAlphanumericSuffix()
        }
        // For asterisk, it can be right emphasis regardless
        return true
    }
    func makeItHead() {
        m_isHead = true
    }
    
    func makeItTail() {
        m_isTail = true
    }
    
    func getBlockType() -> String {
        return "emphasis"
    }
    
    func isNewLine() -> Bool {
        return false
    }
    
    var type: DelimiterType
    var m_numberOfUnusedDelimiters: Int
    var m_token: String
    var m_tags: [String]
    var m_isHead: Bool
    var m_isTail: Bool
    
    init(token: String, type: DelimiterType, delimiterCounts: Int, isHead: Bool = false, isTail: Bool = false) {
        self.m_token = token
        self.type = type
        self.m_numberOfUnusedDelimiters = delimiterCounts
        self.m_tags = []
        self.m_isHead = isHead
        self.m_isTail = isTail
    }
    
    func isLeftAndRightEmphasis() -> Bool {
        // Implement based on your requirements
        return false
    }
    
    func isMatch(_ emphasisToken: MarkDownEmphasisHtmlGenerator) -> Bool {
        if self.type == emphasisToken.type {
            return !(
                (self.isLeftAndRightEmphasis() || emphasisToken.isLeftAndRightEmphasis()) &&
                (((self.m_numberOfUnusedDelimiters + emphasisToken.m_numberOfUnusedDelimiters) % 3) == 0))
        }
        return false
    }
    
    func isSameType(_ token: MarkDownEmphasisHtmlGenerator) -> Bool {
        return self.type == token.type
    }
    
    func adjustEmphasisCounts(leftOver: Int, rightToken: MarkDownEmphasisHtmlGenerator) -> Int {
        var delimiterCount = 0
        if leftOver >= 0 {
            delimiterCount = self.m_numberOfUnusedDelimiters - leftOver
            self.m_numberOfUnusedDelimiters = leftOver
            rightToken.m_numberOfUnusedDelimiters = 0
        } else {
            delimiterCount = self.m_numberOfUnusedDelimiters
            rightToken.m_numberOfUnusedDelimiters = leftOver * (-1)
            self.m_numberOfUnusedDelimiters = 0
        }
        return delimiterCount
    }
    
    func generateTags(token: MarkDownEmphasisHtmlGenerator) -> Bool {
        var delimiterCount = 0
        let leftOver = self.m_numberOfUnusedDelimiters - token.m_numberOfUnusedDelimiters
        delimiterCount = self.adjustEmphasisCounts(leftOver: leftOver, rightToken: token)
        let hasHtmlTags = (delimiterCount > 0)
        
        // emphasis found
        if delimiterCount % 2 != 0 {
            self.pushItalicTag()
            token.pushItalicTag()
        }
        
        // strong emphasis found
        for _ in 0..<(delimiterCount / 2) {
            self.pushBoldTag()
            token.pushBoldTag()
        }
        return hasHtmlTags
    }
    
    func pushItalicTag() {
        m_tags.append("<em>")
    }
    
    func pushBoldTag() {
        m_tags.append("<strong>")
    }
    
    // Added base implementation
    func generateHtmlString() -> String {
        var result = ""
        if m_isHead {
            result += "<p>"
        }
        
        // For left emphasis, append delimiters first
        let delimiter = type == .asterisk ? "*" : "_"
        result += String(repeating: delimiter, count: m_numberOfUnusedDelimiters)
        
        // Then append content
        result += m_token
        
        if m_isTail {
            result += "</p>"
        }
        
        return result
    }
}

class MarkDownLeftEmphasisHtmlGenerator: MarkDownEmphasisHtmlGenerator {
    override func isLeftEmphasis() -> Bool {
        return true
    }
    
    override func isRightEmphasis() -> Bool {
        return false
    }
    
    override func generateHtmlString() -> String {
        var result = ""
        if m_isHead {
            result += "<p>"
        }
        
        // For left emphasis, append delimiters first
        let delimiter = type == .asterisk ? "*" : "_"
        result += String(repeating: delimiter, count: m_numberOfUnusedDelimiters)
        
        // Then append content
        result += m_token
        
        if m_isTail {
            result += "</p>"
        }
        
        return result
    }
}

class MarkDownRightEmphasisHtmlGenerator: MarkDownEmphasisHtmlGenerator {
    override func pushItalicTag() {
        m_tags.append("</em>")
    }
    
    override func pushBoldTag() {
        m_tags.append("</strong>")
    }
    
    override func isLeftEmphasis() -> Bool {
        return false
    }
    
    override func isRightEmphasis() -> Bool {
        return true
    }
    
    override func generateHtmlString() -> String {
        var result = ""
        if m_isHead {
            result += "<p>"
        }
        
        // For right emphasis, append content first
        result += m_token
        
        // Then append delimiters
        let delimiter = type == .asterisk ? "*" : "_"
        result += String(repeating: delimiter, count: m_numberOfUnusedDelimiters)
        
        if m_isTail {
            result += "</p>"
        }
        
        return result
    }
}

class MarkDownLeftAndRightEmphasisHtmlGenerator: MarkDownEmphasisHtmlGenerator {
    var m_directionType: DirectionType
    
    init(token: String, type: DelimiterType, delimiterCounts: Int, directionType: DirectionType, isHead: Bool = false, isTail: Bool = false) {
        self.m_directionType = directionType
        super.init(token: token, type: type, delimiterCounts: delimiterCounts, isHead: isHead, isTail: isTail)
    }
    
    override func pushItalicTag() {
        if m_directionType == .left {
            m_tags.append("<em>")
        } else {
            m_tags.append("</em>")
        }
    }
    
    override func pushBoldTag() {
        if m_directionType == .left {
            m_tags.append("<strong>")
        } else {
            m_tags.append("</strong>")
        }
    }
}

class MarkDownListHtmlGenerator: MarkDownHtmlGenerator {
    var m_token: String
    var m_isHead: Bool
    var m_isTail: Bool
    
    init(token: String, isHead: Bool = false, isTail: Bool = false) {
        self.m_token = token
        self.m_isHead = isHead
        self.m_isTail = isTail
    }
    
    func generateHtmlString() -> String {
        var result = ""
        
        if m_isHead {
            result += "<ul>"
        }
        
        result += m_token
        
        if m_isTail {
            result += "</ul>"
        }
        
        return result
    }

    func makeItHead() {
        m_isHead = true
    }
    
    func makeItTail() {
        m_isTail = true
    }
    
    func getBlockType() -> String {
        return "list"
    }
    
    func isNewLine() -> Bool {
        return false
    }
}

class MarkDownOrderedListHtmlGenerator: MarkDownHtmlGenerator {
    var m_token: String
    var m_numberString: String
    var m_isHead: Bool
    var m_isTail: Bool
    
    init(token: String, numberString: String, isHead: Bool = false, isTail: Bool = false) {
        self.m_token = token
        self.m_numberString = numberString
        self.m_isHead = isHead
        self.m_isTail = isTail
    }
    
    func makeItHead() {
        m_isHead = true
    }
    
    func makeItTail() {
        m_isTail = true
    }
    
    func getBlockType() -> String {
        return "orderedlist"
    }
    
    func isNewLine() -> Bool {
        return false
    }
    
    func generateHtmlString() -> String {
        var result = ""
        
        if m_isHead {
            result += "<ol start=\"\(m_numberString)\">"
        }
        
        result += m_token
        
        if m_isTail {
            result += "</ol>"
        }
        
        return result
    }
}

// Block Parser Implementation
class MarkDownBlockParser {
    var m_parsedResult: MarkDownParsedResult
    
    init() {
        self.m_parsedResult = MarkDownParsedResult()
    }
    
    func parseTextAndEmphasis(_ stream: inout String.SubSequence) {
        let emphasisParser = EmphasisParser()
        emphasisParser.match(&stream) // Use match instead of parse
        m_parsedResult.appendParseResult(emphasisParser.getParsedResult())
    }
    
    func match(_ stream: inout String.SubSequence) {
        // To be implemented by subclasses
    }
    
    func parseBlock(_ stream: inout String.SubSequence) {
        var currentToken = ""
        
        while !stream.isEmpty {
            guard let firstChar = stream.first else { break }
            
            switch firstChar {
            case "[":
                // Handle any accumulated text first
                if !currentToken.isEmpty {
                    m_parsedResult.addNewTokenToParsedResult(currentToken)
                    currentToken = ""
                }
                
                let linkParser = LinkParser()
                linkParser.match(&stream)
                m_parsedResult.appendParseResult(linkParser.getParsedResult())
                
            case "-", "+", "*":
                // Check if this is a list marker
                if stream.count > 1, let nextChar = stream.dropFirst().first, nextChar == " " {
                    // Handle any accumulated text first
                    if !currentToken.isEmpty {
                        m_parsedResult.addNewTokenToParsedResult(currentToken)
                        currentToken = ""
                    }
                    
                    let listParser = ListParser()
                    listParser.match(&stream)
                    m_parsedResult.appendParseResult(listParser.getParsedResult())
                } else {
                    // This is regular text or emphasis
                    handleEmphasisOrText(&stream, &currentToken)
                }
                
            case "0"..."9":
                // Check if this is an ordered list marker
                if isOrderedListMarker(stream) {
                    // Handle any accumulated text first
                    if !currentToken.isEmpty {
                        m_parsedResult.addNewTokenToParsedResult(currentToken)
                        currentToken = ""
                    }
                    
                    let orderedListParser = OrderedListParser()
                    orderedListParser.match(&stream)
                    m_parsedResult.appendParseResult(orderedListParser.getParsedResult())
                } else {
                    handleEmphasisOrText(&stream, &currentToken)
                }
                
            default:
                handleEmphasisOrText(&stream, &currentToken)
            }
        }
        
        // Handle any remaining text
        if !currentToken.isEmpty {
            m_parsedResult.addNewTokenToParsedResult(currentToken)
        }
    }
    
    private func handleEmphasisOrText(_ stream: inout String.SubSequence, _ currentToken: inout String) {
        guard let char = stream.first else { return }
        
        if char == "*" || char == "_" {
            // Handle any accumulated text first
            if !currentToken.isEmpty {
                m_parsedResult.addNewTokenToParsedResult(currentToken)
                currentToken = ""
            }
            
            let emphasisParser = EmphasisParser()
            emphasisParser.match(&stream)
            m_parsedResult.appendParseResult(emphasisParser.getParsedResult())
        } else {
            currentToken.append(char)
            stream.removeFirst()
        }
    }
    
    private func isOrderedListMarker(_ stream: String.SubSequence) -> Bool {
        var numCount = 0
        var index = stream.startIndex
        
        while index < stream.endIndex {
            let char = stream[index]
            if char.isNumber {
                numCount += 1
                index = stream.index(after: index)
            } else {
                break
            }
        }
        
        if numCount > 0 && index < stream.endIndex {
            return stream[index] == "." &&
            stream.index(after: index) < stream.endIndex &&
            stream[stream.index(after: index)] == " "
        }
        
        return false
    }

    static func isSpace(_ ch: UnicodeScalar) -> Bool {
        return ch.value > 0 && CharacterSet.whitespaces.contains(ch)
    }
    
    static func isPunct(_ ch: UnicodeScalar) -> Bool {
        return ch.value > 0 && CharacterSet.punctuationCharacters.contains(ch)
    }
    
    static func isAlnum(_ ch: UnicodeScalar) -> Bool {
        return ch.value > 0x7F || CharacterSet.alphanumerics.contains(ch)
    }
    
    static func isCntrl(_ ch: UnicodeScalar) -> Bool {
        return ch.value > 0 && CharacterSet.controlCharacters.contains(ch)
    }
    
    static func isDigit(_ ch: UnicodeScalar) -> Bool {
        return ch.value > 0 && CharacterSet.decimalDigits.contains(ch)
    }
    
    func getParsedResult() -> MarkDownParsedResult {
        return m_parsedResult
    }
}
// Placeholder for MarkDownParsedResult
class MarkDownParsedResult {
    private var m_codeGenTokens: [MarkDownHtmlGenerator]
    private var m_emphasisLookUpTable: [MarkDownEmphasisHtmlGenerator]
    private var m_isHTMLTagsAdded: Bool
    private var m_isCaptured: Bool
    
    init() {
        m_codeGenTokens = []
        m_emphasisLookUpTable = []
        m_isHTMLTagsAdded = false
        m_isCaptured = false
    }
    
    func translate() {
        matchLeftAndRightEmphasises()
    }
    
    func addBlockTags() {
        // Parsing is done, let code gen token know who is the head of the list
        if let first = m_codeGenTokens.first {
            first.makeItHead()
        }
        
        // Parsing is done, let code gen token know who is the tail of the list
        if let last = m_codeGenTokens.last {
            last.makeItTail()
        }
    }
    
    private func markTags(_ x: MarkDownHtmlGenerator) {
        guard let last = m_codeGenTokens.last else { return }
        
        if last.getBlockType() != x.getBlockType() {
            if last.isNewLine() {
                m_codeGenTokens.removeLast()
            }
            
            if !m_codeGenTokens.isEmpty {
                m_codeGenTokens[m_codeGenTokens.count - 1].makeItTail()
            }
            x.makeItHead()
        }
    }
    
    func appendParseResult(_ x: MarkDownParsedResult) {
        if !m_codeGenTokens.isEmpty && !x.m_codeGenTokens.isEmpty {
            // check if two different block types, then add closing tag followed by opening tag of new type
            if let first = x.m_codeGenTokens.first {
                markTags(first)
            }
        }
        
        m_codeGenTokens.append(contentsOf: x.m_codeGenTokens)
        m_emphasisLookUpTable.append(contentsOf: x.m_emphasisLookUpTable)
        m_isHTMLTagsAdded = m_isHTMLTagsAdded || x.hasHtmlTags()
        setIsCaptured(x.getIsCaptured())
    }
    
    func appendToTokens(_ x: MarkDownHtmlGenerator) {
        if !m_codeGenTokens.isEmpty {
            // check if two different block types, then add closing tag followed by opening tag of new type
            markTags(x)
        }
        m_codeGenTokens.append(x)
    }
    
    func appendToLookUpTable(_ x: MarkDownEmphasisHtmlGenerator) {
        m_emphasisLookUpTable.append(x)
    }
    
    func popFront() {
        if !m_codeGenTokens.isEmpty {
            m_codeGenTokens.removeFirst()
        }
    }
    
    func popBack() {
        if !m_codeGenTokens.isEmpty {
            m_codeGenTokens.removeLast()
        }
    }
    
    func clear() {
        m_codeGenTokens.removeAll()
        m_emphasisLookUpTable.removeAll()
    }
    
    func addNewTokenToParsedResult(_ ch: Int) {
        let stringToken = String(UnicodeScalar(UInt8(ch)))
        let htmlToken = MarkDownStringHtmlGenerator(token: stringToken)
        appendToTokens(htmlToken)
    }
        
    func addNewTokenToParsedResult(_ word: String) {
        let htmlToken = MarkDownStringHtmlGenerator(token: word)
        appendToTokens(htmlToken)
    }
        
    func addNewLineTokenToParsedResult(_ ch: Character) {
        let stringToken = String(ch)
        let htmlToken = ConcreteMarkDownNewLineHtmlGenerator(token: stringToken)
        appendToTokens(htmlToken)
    }
    
    func generateHtmlString() -> String {
        var html = ""
        for token in m_codeGenTokens {
            html += token.generateHtmlString()
        }
        return html
    }
    
    func matchLeftAndRightEmphasises() {
        var leftEmphasisToExplore: [Int] = [] // Stores indices into m_emphasisLookUpTable
        var currentIndex = 0
        
        while currentIndex < m_emphasisLookUpTable.count {
            let currentEmphasis = m_emphasisLookUpTable[currentIndex]
            
            if currentEmphasis.isLeftEmphasis() ||
                (currentEmphasis.isLeftAndRightEmphasis() && leftEmphasisToExplore.isEmpty) {
                if currentEmphasis.isLeftAndRightEmphasis() && currentEmphasis.isRightEmphasis() {
                    currentEmphasis.changeDirectionToLeft()
                }
                
                leftEmphasisToExplore.append(currentIndex)
                currentIndex += 1
            } else if !leftEmphasisToExplore.isEmpty {
                let currentLeftIndex = leftEmphasisToExplore.last!
                var currentLeftEmphasis = m_emphasisLookUpTable[currentLeftIndex]
                
                if !currentLeftEmphasis.isMatch(currentEmphasis) {
                    var store: [Int] = []
                    var isFound = false
                    
                    while !leftEmphasisToExplore.isEmpty && !isFound {
                        let leftTokenIndex = leftEmphasisToExplore.last!
                        let leftToken = m_emphasisLookUpTable[leftTokenIndex]
                        
                        if leftToken.isMatch(currentEmphasis) {
                            currentLeftEmphasis = leftToken
                            isFound = true
                        } else {
                            leftEmphasisToExplore.removeLast()
                            store.append(leftTokenIndex)
                        }
                    }
                    
                    if !isFound {
                        // Restore state
                        while !isFound && !store.isEmpty {
                            leftEmphasisToExplore.append(store.removeLast())
                        }
                        
                        if leftEmphasisToExplore.isEmpty {
                            currentIndex += 1
                            continue
                        }
                        
                        let lastLeftEmphasis = m_emphasisLookUpTable[leftEmphasisToExplore.last!]
                        
                        if lastLeftEmphasis.isSameType(currentEmphasis) {
                            currentEmphasis.changeDirectionToLeft()
                        } else {
                            currentIndex += 1
                        }
                        continue
                    }
                }
                
                m_isHTMLTagsAdded = currentLeftEmphasis.generateTags(token: currentEmphasis) || m_isHTMLTagsAdded
                
                if currentEmphasis.isDone() {
                    currentIndex += 1
                }
                
                if currentLeftEmphasis.isDone() {
                    leftEmphasisToExplore.removeLast()
                }
            } else {
                currentIndex += 1
            }
        }
    }
    
    func hasHtmlTags() -> Bool {
        return m_isHTMLTagsAdded
    }
    
    func foundHtmlTags() {
        m_isHTMLTagsAdded = true
    }
    
    func getIsCaptured() -> Bool {
        return m_isCaptured
    }
    
    func setIsCaptured(_ val: Bool) {
        m_isCaptured = val
    }
}

// Add required protocols to base classes
protocol MarkDownHtmlGenerator {
    func makeItHead()
    func makeItTail()
    func getBlockType() -> String // You might want to use an enum instead
    func isNewLine() -> Bool
    func generateHtmlString() -> String
}

protocol MarkDownNewLineHtmlGenerator: MarkDownHtmlGenerator {
    // Add any specific requirements for NewLine generator
}

extension MarkDownEmphasisHtmlGenerator {
    private func hasAlphanumericPrefix() -> Bool {
        // Check if token starts with alphanumeric
        guard let firstChar = m_token.first,
              let unicodeScalar = firstChar.unicodeScalars.first else {
            return false
        }
        return MarkDownBlockParser.isAlnum(unicodeScalar)
    }
        
    private func hasAlphanumericSuffix() -> Bool {
        // Check if token ends with alphanumeric
        guard let lastChar = m_token.last,
              let unicodeScalar = lastChar.unicodeScalars.first else {
            return false
        }
        return MarkDownBlockParser.isAlnum(unicodeScalar)
    }
    
    func changeDirectionToLeft() {
        // For left and right emphasis tokens, allow switching direction
        m_tags = m_tags.map { tag in
            if tag == "</em>" { return "<em>" }
            if tag == "</strong>" { return "<strong>" }
            return tag
        }
    }
    
    func isDone() -> Bool {
        return m_numberOfUnusedDelimiters == 0
    }
}

class ConcreteMarkDownNewLineHtmlGenerator: MarkDownNewLineHtmlGenerator {
    private var m_token: String
    private var m_isHead: Bool
    private var m_isTail: Bool
    
    init(token: String, isHead: Bool = false, isTail: Bool = false) {
        self.m_token = token
        self.m_isHead = isHead
        self.m_isTail = isTail
    }
    
    func generateHtmlString() -> String {
        return m_token
    }
    
    func makeItHead() {
        m_isHead = true
    }
    
    func makeItTail() {
        m_isTail = true
    }
    
    func getBlockType() -> String {
        return "newline"
    }
    
    func isNewLine() -> Bool {
        return true
    }
}

class EmphasisParser: MarkDownBlockParser {
    enum EmphasisState {
        case text     // Text is being handled
        case emphasis // Emphasis is being handled
        case captured // Emphasis parsing is complete
    }
    
    public struct ParserState {
        var checkLookAhead: Bool = false
        var checkIntraWord: Bool = false
        var lookBehind: DelimiterType = .`init`
        var delimiterCnts: Int = 0
        var currentDelimiterType: DelimiterType = .`init`
        var currentState: EmphasisState = .text
        var currentToken: String = ""
        var isProcessingEmphasis: Bool = false
    }
    
    override func match(_ stream: inout String.SubSequence) {
        var state = ParserState()
        processEmphasis(&stream, &state)
    }
    
    private func processEmphasis(_ stream: inout String.SubSequence, _ state: inout ParserState) {
            while state.currentState != .captured {
                if state.currentState == .text {
                    state.currentState = Self.matchText(self, &stream, &state)
                } else if state.currentState == .emphasis {
                    state.currentState = Self.matchEmphasis(self, &stream, &state)
                }
            }
        }
        
        static func isEmphasisToken(_ currentChar: Character) -> Bool {
            return "[])\\n\\r".contains(currentChar)
        }

    public func parse(_ stream: inout String.SubSequence, _ state: inout ParserState) {
        while state.currentState != .captured {
            if state.currentState == .text {
                state.currentState = Self.matchText(self, &stream, &state)
            } else if state.currentState == .emphasis {
                state.currentState = Self.matchEmphasis(self, &stream, &state)
            }
        }
    }
    
    private func captureCurrentCollectedStringAsRegularToken(_ token: String) {
        guard !token.isEmpty else { return }
        let codeGen = MarkDownStringHtmlGenerator(token: token)
        m_parsedResult.appendToTokens(codeGen)
    }
    
    private static func matchText(_ parser: EmphasisParser, _ stream: inout String.SubSequence, _ state: inout ParserState) -> EmphasisState {
            guard let currentChar = stream.first else {
                parser.flushCurrentToken(&state)
                return .captured
            }
            
            let isEmphasisToken = isEmphasisToken(currentChar)
            
            if isEmphasisToken && state.lookBehind != .escape {
                parser.flushCurrentToken(&state)
                return .captured
            }
            
            if parser.isMarkDownDelimiter(currentChar, lookBehind: state.lookBehind) {
                // If we have accumulated text, flush it first
                if !state.currentToken.isEmpty {
                    parser.flushCurrentToken(&state)
                }
                
                let emphasisType = getDelimiterTypeForChar(currentChar)
                
                // Check if this could be a valid delimiter
                if !stream.isEmpty {
                    let nextChar = stream.dropFirst().first
                    state.lookBehind = parser.lookAheadForEmphasis(nextChar, &state)
                    
                    // If this is an underscore that's part of a word, treat it as text
                    if emphasisType == .underscore &&
                       ((state.lookBehind == .alphanumeric && !state.isProcessingEmphasis) ||
                        state.lookBehind == .whiteSpace) {
                        state.currentToken.append(currentChar)
                        stream.removeFirst()
                        return .text
                    }
                }
                
                parser.updateEmphasisState(&state, emphasisType)
                stream.removeFirst()
                state.currentToken.append(currentChar)
                state.isProcessingEmphasis = true
                return .emphasis
            } else {
                if state.lookBehind == .escape {
                    if isEmphasisToken || currentChar == "*" || currentChar == "_" {
                        if !state.currentToken.isEmpty {
                            state.currentToken.removeLast() // Remove the escape character
                        }
                    }
                }
                
                state.lookBehind = parser.getUpdatedLookBehind(currentChar)
                stream.removeFirst()
                state.currentToken.append(currentChar)
                return .text
            }
        }
    
    private static func matchEmphasis(_ parser: EmphasisParser, _ stream: inout String.SubSequence, _ state: inout ParserState) -> EmphasisState {
            guard let currentChar = stream.first else {
                parser.flushCurrentToken(&state)
                return .captured
            }
            
            if isEmphasisToken(currentChar) {
                parser.flushCurrentToken(&state)
                return .captured
            }
            
            if parser.isMarkDownDelimiter(currentChar, lookBehind: state.lookBehind) {
                let emphasisType = getDelimiterTypeForChar(currentChar)
                if state.currentDelimiterType == emphasisType {
                    state.delimiterCnts += 1
                    stream.removeFirst()
                    state.currentToken.append(currentChar)
                    return .emphasis
                } else {
                    parser.captureEmphasisToken(currentChar, &state)
                    state.isProcessingEmphasis = false
                    return .text
                }
            } else {
                if parser.shouldCloseEmphasis(currentChar, &state) {
                    parser.captureEmphasisToken(currentChar, &state)
                    state.isProcessingEmphasis = false
                    
                    if currentChar == "\\" {
                        stream.removeFirst()
                    }
                    
                    if let nextChar = stream.dropFirst().first {
                        state.lookBehind = parser.getUpdatedLookBehind(nextChar)
                    }
                    stream.removeFirst()
                    state.currentToken = String(currentChar)
                    return .text
                }
                
                stream.removeFirst()
                state.currentToken.append(currentChar)
                return .emphasis
            }
        }
    private func isMarkDownDelimiter(_ ch: Character, lookBehind: DelimiterType) -> Bool {
            return (ch == "*" || ch == "_") && lookBehind != .escape
        }
    private func shouldCloseEmphasis(_ currentChar: Character, _ state: inout ParserState) -> Bool {
            // Close emphasis if we see whitespace or punctuation
            guard let unicodeScalar = currentChar.unicodeScalars.first else { return false }
            return MarkDownBlockParser.isSpace(unicodeScalar) ||
                   MarkDownBlockParser.isPunct(unicodeScalar) ||
                   state.delimiterCnts >= 2
        }
        
        private func lookAheadForEmphasis(_ nextChar: Character?, _ state: inout ParserState) -> DelimiterType {
            guard let char = nextChar, let unicodeScalar = char.unicodeScalars.first else {
                return .`init`
            }
            
            if MarkDownBlockParser.isAlnum(unicodeScalar) {
                return .alphanumeric
            } else if MarkDownBlockParser.isSpace(unicodeScalar) {
                return .whiteSpace
            } else if MarkDownBlockParser.isPunct(unicodeScalar) {
                return char == "\\" ? .escape : .punctuation
            }
            return .`init`
        }
        
        private func flushCurrentToken(_ state: inout ParserState) {
            if !state.currentToken.isEmpty {
                captureCurrentCollectedStringAsRegularToken(state.currentToken)
                state.currentToken = ""
            }
        }
    
    private func flush(_ ch: Character?, state: inout ParserState) {
        if state.currentState == .emphasis {
            captureEmphasisToken(ch ?? "\0", &state)
            state.delimiterCnts = 0
        } else {
            captureCurrentCollectedStringAsRegularToken(state.currentToken)
        }
        state.currentToken = ""
    }
    
    private func captureEmphasisToken(_ ch: Character, _ state: inout ParserState) {
            if !tryCapturingRightEmphasisToken(ch, &state) &&
               !tryCapturingLeftEmphasisToken(ch, &state) {
                // If no emphasis was captured and we have content, treat it as regular text
                if !state.currentToken.isEmpty {
                    captureCurrentCollectedStringAsRegularToken(state.currentToken)
                }
            }
            state.delimiterCnts = 0
            state.currentToken = ""
        }
    
    private func tryCapturingRightEmphasisToken(_ ch: Character, _ state: inout ParserState) -> Bool {
            if isRightEmphasisDelimiter(ch, state) {
                var codeGen: MarkDownEmphasisHtmlGenerator
                
                if isLeftEmphasisDelimiter(ch, state) {
                    codeGen = MarkDownLeftAndRightEmphasisHtmlGenerator(
                        token: state.currentToken,
                        type: state.currentDelimiterType,
                        delimiterCounts: state.delimiterCnts,
                        directionType: .right
                    )
                } else {
                    codeGen = MarkDownRightEmphasisHtmlGenerator(
                        token: state.currentToken,
                        type: state.currentDelimiterType,
                        delimiterCounts: state.delimiterCnts
                    )
                }
                
                m_parsedResult.appendToLookUpTable(codeGen)
                m_parsedResult.appendToTokens(codeGen)
                return true
            }
            return false
        }
    
    private func tryCapturingLeftEmphasisToken(_ ch: Character, _ state: inout ParserState) -> Bool {
            if isLeftEmphasisDelimiter(ch, state) {
                let codeGen = MarkDownLeftEmphasisHtmlGenerator(
                    token: state.currentToken,
                    type: state.currentDelimiterType,
                    delimiterCounts: state.delimiterCnts
                )
                
                m_parsedResult.appendToLookUpTable(codeGen)
                m_parsedResult.appendToTokens(codeGen)
                return true
            }
            return false
        }
    
    private func isLeftEmphasisDelimiter(_ ch: Character, _ state: ParserState) -> Bool {
            guard state.delimiterCnts > 0 else { return false }
            guard let unicodeScalar = ch.unicodeScalars.first else { return false }
            
            if MarkDownBlockParser.isSpace(unicodeScalar) { return false }
            if state.lookBehind == .alphanumeric && MarkDownBlockParser.isPunct(unicodeScalar) { return false }
            if state.lookBehind == .alphanumeric && state.currentDelimiterType == .underscore { return false }
            
            return true
        }
        
        private func isRightEmphasisDelimiter(_ ch: Character, _ state: ParserState) -> Bool {
            guard let unicodeScalar = ch.unicodeScalars.first else {
                return state.lookBehind != .whiteSpace &&
                       (state.checkLookAhead || state.checkIntraWord || state.currentDelimiterType == .asterisk)
            }
            
            if MarkDownBlockParser.isSpace(unicodeScalar) {
                return state.lookBehind != .whiteSpace &&
                       (state.checkLookAhead || state.checkIntraWord || state.currentDelimiterType == .asterisk)
            }
            
            if MarkDownBlockParser.isAlnum(unicodeScalar) {
                if state.lookBehind == .whiteSpace || state.lookBehind == .`init` { return false }
                if state.checkLookAhead || state.checkIntraWord { return false }
                return true
            }
            
            return MarkDownBlockParser.isPunct(unicodeScalar) && state.lookBehind != .whiteSpace
        }
        
        private static func getDelimiterTypeForChar(_ ch: Character) -> DelimiterType {
            return ch == "*" ? .asterisk : .underscore
        }
        
        private func updateEmphasisState(_ state: inout ParserState, _ emphasisType: DelimiterType) {
            if state.lookBehind != .whiteSpace {
                state.checkLookAhead = (state.lookBehind == .punctuation)
                state.checkIntraWord = (state.lookBehind == .alphanumeric && emphasisType == .underscore)
            }
            state.delimiterCnts += 1
            state.currentDelimiterType = emphasisType
        }
        
        private func getUpdatedLookBehind(_ ch: Character) -> DelimiterType {
            guard let unicodeScalar = ch.unicodeScalars.first else { return .`init` }
            
            if MarkDownBlockParser.isAlnum(unicodeScalar) {
                return .alphanumeric
            } else if MarkDownBlockParser.isSpace(unicodeScalar) {
                return .whiteSpace
            } else if MarkDownBlockParser.isPunct(unicodeScalar) {
                return ch == "\\" ? .escape : .punctuation
            }
            return .`init`
        }
    private func isEmphasisDelimiterRun(_ emphasisType: DelimiterType, currentType: DelimiterType) -> Bool {
        return currentType == emphasisType
    }
    
    private func updateCurrentEmphasisRunState(_ state: inout ParserState, _ emphasisType: DelimiterType) {
        state.delimiterCnts += 1
        state.currentDelimiterType = emphasisType
    }
    
    private func resetCurrentEmphasisState(_ state: inout ParserState) {
        state.delimiterCnts = 0
    }
    
    private func isLeftEmphasisDelimiter(_ ch: Character?, _ state: ParserState) -> Bool {
        guard state.delimiterCnts > 0, let ch = ch else { return false }
        
        guard let unicodeScalar = ch.unicodeScalars.first else { return false }
        
        return !MarkDownBlockParser.isSpace(unicodeScalar) &&
               !(state.lookBehind == .alphanumeric && MarkDownBlockParser.isPunct(unicodeScalar)) &&
               !(state.lookBehind == .alphanumeric && state.currentDelimiterType == .underscore)
    }
    
    private func isRightEmphasisDelimiter(_ ch: Character?, _ state: ParserState) -> Bool {
        guard let ch = ch else {
            return state.lookBehind != .whiteSpace &&
                   (state.checkLookAhead || state.checkIntraWord || state.currentDelimiterType == .asterisk)
        }
        
        guard let unicodeScalar = ch.unicodeScalars.first else { return false }
        
        if MarkDownBlockParser.isSpace(unicodeScalar) {
            return state.lookBehind != .whiteSpace &&
                   (state.checkLookAhead || state.checkIntraWord || state.currentDelimiterType == .asterisk)
        }
        
        if MarkDownBlockParser.isAlnum(unicodeScalar) &&
           state.lookBehind != .whiteSpace &&
           state.lookBehind != .`init` {
            if !state.checkLookAhead && !state.checkIntraWord {
                return true
            }
            if state.checkLookAhead || state.checkIntraWord {
                return false
            }
        }
        
        if MarkDownBlockParser.isPunct(unicodeScalar) && state.lookBehind != .whiteSpace {
            return true
        }
        
        return false
    }
    
    private func tryCapturingRightEmphasisToken(_ ch: Character, state: inout ParserState) -> Bool {
        if isRightEmphasisDelimiter(ch, state) {
            var codeGen: MarkDownEmphasisHtmlGenerator
            
            if isLeftEmphasisDelimiter(ch, state) {
                codeGen = MarkDownLeftAndRightEmphasisHtmlGenerator(
                    token: state.currentToken,
                    type: state.currentDelimiterType,
                    delimiterCounts: state.delimiterCnts,
                    directionType: .right
                )
            } else {
                codeGen = MarkDownRightEmphasisHtmlGenerator(
                    token: state.currentToken,
                    type: state.currentDelimiterType,
                    delimiterCounts: state.delimiterCnts
                )
            }
            
            m_parsedResult.appendToLookUpTable(codeGen)
            m_parsedResult.appendToTokens(codeGen)
            
            state.currentToken = ""
            return true
        }
        return false
    }
    
    private func tryCapturingLeftEmphasisToken(_ ch: Character, state: inout ParserState) -> Bool {
        if isLeftEmphasisDelimiter(ch, state) {
            let codeGen = MarkDownLeftEmphasisHtmlGenerator(
                token: state.currentToken,
                type: state.currentDelimiterType,
                delimiterCounts: state.delimiterCnts
            )
            
            m_parsedResult.appendToLookUpTable(codeGen)
            m_parsedResult.appendToTokens(codeGen)
            
            state.currentToken = ""
            return true
        }
        return false
    }
}
    // Previous code remains, adding the remaining parser classes...

    class LinkParser: MarkDownBlockParser {
        private var m_leftBracketCounts = 0
        private var m_leftParenthesisCounts = 0
        private var m_linkTextParsedResult = MarkDownParsedResult()
        private var m_linkDestination = ""

        override func match(_ stream: inout String.SubSequence) {
            // Start with opening bracket
            guard !stream.isEmpty, stream.first == "[" else { return }
            
            // Track all brackets and parse until we find the matching close
            var originalText = ""
            var bracketCount = 1
            
            // Add opening bracket to original text
            originalText += "["
            stream.removeFirst()
            
            while !stream.isEmpty && bracketCount > 0 {
                let char = stream.removeFirst()
                originalText += String(char)
                
                if char == "[" {
                    bracketCount += 1
                } else if char == "]" {
                    bracketCount -= 1
                }
            }
            
            // If brackets matched, look for destination
            if bracketCount == 0 && !stream.isEmpty && stream.first == "(" {
                stream.removeFirst()
                originalText += "("
                
                // Parse destination
                var parenCount = 1
                while !stream.isEmpty && parenCount > 0 {
                    let char = stream.removeFirst()
                    originalText += String(char)
                    
                    if char == "(" {
                        parenCount += 1
                    } else if char == ")" {
                        parenCount -= 1
                    }
                }
                
                // Complete link found
                if parenCount == 0 {
                    m_parsedResult.addNewTokenToParsedResult(originalText)
                    return
                }
            }
            
            // If we get here, link syntax was invalid
            // Just output what we've collected as plain text
            m_parsedResult.addNewTokenToParsedResult(originalText)
            
            // Continue parsing any remaining content
            while !stream.isEmpty {
                let char = stream.removeFirst()
                m_parsedResult.addNewTokenToParsedResult(String(char))
            }
        }
    }

class ListParser: MarkDownBlockParser {
    static func isHyphen(_ ch: Character) -> Bool { return ch == "-" }
    static func isPlus(_ ch: Character) -> Bool { return ch == "+" }
    static func isAsterisk(_ ch: Character) -> Bool { return ch == "*" }
    static func isDot(_ ch: Character) -> Bool { return ch == "." }
    static func isNewLine(_ ch: Character) -> Bool { return ch == "\r" || ch == "\n" }
    
    override func match(_ stream: inout String.SubSequence) {
        guard let firstChar = stream.first else { return }
        
        if ListParser.isHyphen(firstChar) || ListParser.isPlus(firstChar) || ListParser.isAsterisk(firstChar) {
            stream.removeFirst()
            if completeListParsing(&stream) {
                captureListToken()
            } else if ListParser.isAsterisk(firstChar) {
                // If asterisk, could be emphasis
                stream.insert(firstChar, at: stream.startIndex)
                parseTextAndEmphasis(&stream)
            } else {
                m_parsedResult.addNewTokenToParsedResult(Int(firstChar.asciiValue ?? 0))
            }
        }
    }
    
    func completeListParsing(_ stream: inout String.SubSequence) -> Bool {
        guard let firstChar = stream.first, firstChar == " " else { return false }
        
        // Remove spaces
        while !stream.isEmpty, stream.first == " " {
            stream.removeFirst()
        }
        
        parseBlock(&stream)
        parseSubBlocks(&stream)
        
        return true
    }
    
    func parseSubBlocks(_ stream: inout String.SubSequence) {
        while !stream.isEmpty {
            if stream.first.map(ListParser.isNewLine) ?? false {
                let newline = stream.removeFirst()
                
                if let nextChar = stream.first,
                   let unicodeScalar = nextChar.unicodeScalars.first,
                   MarkDownBlockParser.isDigit(unicodeScalar) {
                    var numberString = ""
                    if matchNewOrderedListItem(&stream, numberString: &numberString) {
                        break
                    } else {
                        m_parsedResult.addNewTokenToParsedResult(numberString)
                    }
                } else if matchNewListItem(&stream) || matchNewBlock(&stream) {
                    break
                }
                
                m_parsedResult.addNewLineTokenToParsedResult(newline)
            }
            parseBlock(&stream)
        }
    }
    
    func matchNewListItem(_ stream: inout String.SubSequence) -> Bool {
        guard let char = stream.first else { return false }
        
        if ListParser.isHyphen(char) || ListParser.isPlus(char) || ListParser.isAsterisk(char) {
            stream.removeFirst()
            if stream.first == " " {
                stream.insert(char, at: stream.startIndex)
                return true
            }
            stream.insert(char, at: stream.startIndex)
        }
        return false
    }
    
    func matchNewBlock(_ stream: inout String.SubSequence) -> Bool {
        guard stream.first.map(ListParser.isNewLine) ?? false else { return false }
        
        while !stream.isEmpty, stream.first.map(ListParser.isNewLine) ?? false {
            stream.removeFirst()
        }
        
        return true
    }
    
    func matchNewOrderedListItem(_ stream: inout String.SubSequence, numberString: inout String) -> Bool {
        while !stream.isEmpty,
              let char = stream.first,
              let unicodeScalar = char.unicodeScalars.first,
              MarkDownBlockParser.isDigit(unicodeScalar) {
            stream.removeFirst()
            numberString.append(char)
        }
        
        guard stream.first.map(ListParser.isDot) ?? false else { return false }
        
        stream.insert(contentsOf: numberString, at: stream.startIndex)
        return true
    }
    
    public func captureListToken() {
        m_parsedResult.translate()
        let content = m_parsedResult.generateHtmlString()
        
        let listItem = "<li>" + content + "</li>"
        let codeGen = MarkDownListHtmlGenerator(token: listItem)
        
        m_parsedResult.clear()
        m_parsedResult.foundHtmlTags()
        m_parsedResult.appendToTokens(codeGen)
    }
}

class OrderedListParser: ListParser {
    override func match(_ stream: inout String.SubSequence) {
        var numberString = ""
        
        guard let firstChar = stream.first,
              let unicodeScalar = firstChar.unicodeScalars.first,
              MarkDownBlockParser.isDigit(unicodeScalar) else { return }
        
        // Collect number
        while !stream.isEmpty,
              let char = stream.first,
              let unicodeScalar = char.unicodeScalars.first,
              MarkDownBlockParser.isDigit(unicodeScalar) {
            stream.removeFirst()
            numberString.append(char)
        }
        
        // Check for dot
        guard !stream.isEmpty, stream.first == "." else {
            m_parsedResult.addNewTokenToParsedResult(numberString)
            return
        }
        
        stream.removeFirst()
        if completeListParsing(&stream) {
            captureOrderedListToken(numberString)
        } else {
            m_parsedResult.addNewTokenToParsedResult(numberString + ".")
        }
    }
    
    private func captureOrderedListToken(_ numberString: String) {
        m_parsedResult.translate()
        let content = m_parsedResult.generateHtmlString()
        
        let listItem = "<li>" + content + "</li>"
        let codeGen = MarkDownOrderedListHtmlGenerator(token: listItem, numberString: numberString)
        
        m_parsedResult.clear()
        m_parsedResult.foundHtmlTags()
        m_parsedResult.appendToTokens(codeGen)
    }
}

// Add this class to the existing file

class MarkDownParser {
    private var m_text: String
    private var m_parsedResult: MarkDownParsedResult
    private var m_hasHTMLTag: Bool
    private var m_isEscaped: Bool
    
    init(txt: String) {
        self.m_text = txt
        self.m_parsedResult = MarkDownParsedResult()
        self.m_hasHTMLTag = false
        self.m_isEscaped = false
    }
    
    func transformToHtml() -> String {
        if m_text.isEmpty {
            return "<p></p>"
        }
        
        // Begin parsing html blocks
        let escapedText = escapeText()
        var stream = escapedText[...] // Convert to SubSequence
        
        // Create a single block parser for the entire text
        let blockParser = MarkDownBlockParser()
        blockParser.parseBlock(&stream)
        
        // Get the result and process it
        m_parsedResult = blockParser.getParsedResult()
        m_parsedResult.translate()
        m_parsedResult.addBlockTags()
        
        m_hasHTMLTag = m_parsedResult.hasHtmlTags()
        return m_parsedResult.generateHtmlString()
    }
    
    private func escapeText() -> String {
        var escaped = ""
        var nonEscapedCounts = 0
        
        // Handle consecutive characters
        var prevChar: Character?
        
        for char in m_text {
            // Handle special characters
            let escapedChar = switch char {
            case "<": "&lt;"
            case ">": "&gt;"
            case "\"": "&quot;"
            case "&": "&amp;"
            default: String(char)
            }
            
            // Add the escaped character
            escaped += escapedChar
            
            // Count non-escaped characters
            if escapedChar.count == 1 {
                nonEscapedCounts += 1
            }
            
            prevChar = char
        }
        
        m_isEscaped = (nonEscapedCounts != m_text.count)
        return escaped
    }
    
    func hasHtmlTags() -> Bool {
        return m_hasHTMLTag
    }
    
    func isEscaped() -> Bool {
        return m_isEscaped
    }
    
    func getRawText() -> String {
        return m_text
    }
}
