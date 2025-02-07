import Foundation

class MarkDownParsedResult {
    private var codeGenTokens: [MarkDownHtmlGenerator] = []
    private var emphasisLookUpTable: [MarkDownEmphasisHtmlGenerator] = []
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

                isHTMLTagsAdded = currentLeftEmphasis.generateTags(with: currentEmphasis) || isHTMLTagsAdded

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
