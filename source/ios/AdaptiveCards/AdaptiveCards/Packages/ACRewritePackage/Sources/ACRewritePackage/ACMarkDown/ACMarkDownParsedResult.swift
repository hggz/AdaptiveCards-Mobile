import Foundation

// Define the protocol for MarkDownHtmlGenerator
protocol SwiftACMarkDownHtmlGenerator {
    var token: String { get set }
    var isHead: Bool { get set }
    var isTail: Bool { get set }
    
    mutating func makeItHead()
    mutating func makeItTail()
    func isNewLine() -> Bool
    func generateHtmlString() -> String
    func getBlockType() -> SwiftACMarkDownBlockType
}

// Default implementations for the protocol methods
extension SwiftACMarkDownHtmlGenerator {
    mutating func makeItHead() {
        isHead = true
    }
    
    mutating func makeItTail() {
        isTail = true
    }
    
    func isNewLine() -> Bool {
        return false
    }
    
    func getBlockType() -> SwiftACMarkDownBlockType {
        return .containerBlock
    }
}

// Enum for block types
enum SwiftACMarkDownBlockType {
    case containerBlock
    case unorderedList
    case orderedList
}


// Implementation for MarkDownStringHtmlGenerator
struct SwiftACMarkDownStringHtmlGenerator: SwiftACMarkDownHtmlGenerator {
    var token: String
    var isHead: Bool = false
    var isTail: Bool = false
    
    func generateHtmlString() -> String {
        var result = token
        if isHead {
            result = "<p>" + result
        }
        if isTail {
            result += "</p>"
        }
        return result
    }
}

// Implementation for MarkDownNewLineHtmlGenerator
struct SwiftACMarkDownNewLineHtmlGenerator: SwiftACMarkDownHtmlGenerator {
    var token: String
    var isHead: Bool = false
    var isTail: Bool = false
    
    func isNewLine() -> Bool {
        return true
    }
    
    func generateHtmlString() -> String {
        return token
    }
}

// Implementation for MarkDownEmphasisHtmlGenerator
class SwiftACMarkDownEmphasisHtmlGenerator: SwiftACMarkDownHtmlGenerator {
    var token: String
    var isHead: Bool = false
    var isTail: Bool = false
    var numberOfUnusedDelimiters: Int
    var directionType: DirectionType = .right
    var type: SwiftACDelimiterType
    var tags: [String] = []
    
    init(token: String, sizeOfEmphasisDelimiterRun: Int, type: SwiftACDelimiterType) {
        self.token = token
        self.numberOfUnusedDelimiters = sizeOfEmphasisDelimiterRun
        self.type = type
    }
    
    func generateHtmlString() -> String {
        // Implement the method to generate HTML string
        return ""
    }
    
    func pushItalicTag() {
        tags.append("<em>")
    }
    
    func pushBoldTag() {
        tags.append("<strong>")
    }
    
    func isRightEmphasis() -> Bool {
        return directionType == .right
    }
    
    func isLeftEmphasis() -> Bool {
        return directionType == .left
    }
    
    func isLeftAndRightEmphasis() -> Bool {
        return false
    }
    
    func isMatch(_ token: SwiftACMarkDownEmphasisHtmlGenerator) -> Bool {
        if self.type == token.type {
            return !((self.isLeftAndRightEmphasis() || token.isLeftAndRightEmphasis()) &&
                     ((self.numberOfUnusedDelimiters + token.numberOfUnusedDelimiters) % 3 == 0))
        }
        return false
    }
    
    func isSameType(_ token: SwiftACMarkDownEmphasisHtmlGenerator) -> Bool {
        return self.type == token.type
    }
    
    func isDone() -> Bool {
        return numberOfUnusedDelimiters == 0
    }
    
    func generateTags(_ token: inout SwiftACMarkDownEmphasisHtmlGenerator) -> Bool {
        var delimiterCount = 0
        let leftOver = self.numberOfUnusedDelimiters - token.numberOfUnusedDelimiters
        delimiterCount = self.adjustEmphasisCounts(leftOver, rightToken: &token)
        let hasHtmlTags = (delimiterCount > 0)
        
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
        directionType = .left
    }
    
    private func adjustEmphasisCounts(_ leftOver: Int, rightToken: inout SwiftACMarkDownEmphasisHtmlGenerator) -> Int {
        var delimiterCount = 0
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
    
    enum DirectionType {
        case left
        case right
    }
}

// Implementation for MarkDownLeftEmphasisHtmlGenerator
class SwiftACMarkDownLeftEmphasisHtmlGenerator: SwiftACMarkDownEmphasisHtmlGenerator {
    override func isLeftEmphasis() -> Bool {
        return true
    }
    
    override func isLeftAndRightEmphasis() -> Bool {
        return false
    }
}

// Implementation for MarkDownRightEmphasisHtmlGenerator
class SwiftACMarkDownRightEmphasisHtmlGenerator: SwiftACMarkDownEmphasisHtmlGenerator {
    override func isRightEmphasis() -> Bool {
        return true
    }
    
    override func isLeftAndRightEmphasis() -> Bool {
        return false
    }
    
    override func generateHtmlString() -> String {
        // Implement the method to generate HTML string
        return ""
    }
}

// Implementation for MarkDownLeftAndRightEmphasisHtmlGenerator
class SwiftACMarkDownLeftAndRightEmphasisHtmlGenerator: SwiftACMarkDownRightEmphasisHtmlGenerator {
    override func isLeftAndRightEmphasis() -> Bool {
        return true
    }
}

// Implementation for MarkDownOrderedListHtmlGenerator
struct SwiftACMarkDownOrderedListHtmlGenerator: SwiftACMarkDownHtmlGenerator {
    var token: String
    var isHead: Bool = false
    var isTail: Bool = false
    var numberString: String
    
    func generateHtmlString() -> String {
        var result = token
        if isHead {
            result = "<ol start=\"" + numberString + "\">" + result
        }
        if isTail {
            result += "</ol>"
        }
        return result
    }
}


