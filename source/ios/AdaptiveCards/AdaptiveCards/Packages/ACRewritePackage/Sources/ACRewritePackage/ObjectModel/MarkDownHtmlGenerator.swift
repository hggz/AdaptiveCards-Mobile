import Foundation

enum DelimiterType {
    case initType, alphanumeric, punctuation, escape, whiteSpace, underscore, asterisk
}

enum MarkDownBlockType {
    case containerBlock, unorderedList, orderedList
}

class MarkDownHtmlGenerator {
    var numberOfUnusedDelimiters: Int = 0
    var directionType: Int = 0 // default to 0 (left)
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
        
        if numberOfUnusedDelimiters > 0 {
            let startIdx = token.index(token.endIndex, offsetBy: -numberOfUnusedDelimiters)
            html += String(token[startIdx...])
        }
        
        for tag in tags.reversed() {
            html += tag
        }
        
        if isTail { html += "</p>" }
        return html
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
        
        for tag in tags {
            html += tag
        }
        
        if numberOfUnusedDelimiters > 0 {
            let startIdx = token.index(token.endIndex, offsetBy: -numberOfUnusedDelimiters)
            html += String(token[startIdx...])
        }
        
        if isTail { html += "</p>" }
        return html
    }
}

// - MarkDownLeftAndRightEmphasisHtmlGenerator
class MarkDownLeftAndRightEmphasisHtmlGenerator: MarkDownRightEmphasisHtmlGenerator {
    override func isLeftAndRightEmphasis() -> Bool { return true }
    
    override func pushItalicTag() {
        tags.append(directionType == 0 ? "<em>" : "</em>")
    }
    
    override func pushBoldTag() {
        tags.append(directionType == 0 ? "<strong>" : "</strong>")
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
