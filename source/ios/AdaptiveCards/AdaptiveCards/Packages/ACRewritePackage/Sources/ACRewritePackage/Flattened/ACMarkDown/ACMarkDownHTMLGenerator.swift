//
//  ACMarkDownHTMLGenerator.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation

// Define the protocol for MarkDownParsedResult
protocol SwiftACMarkDownParsedResultProtocol {
    func translate()
    func addBlockTags()
    func generateHtmlString() -> String
    func appendParseResult(_ result: SwiftACMarkDownParsedResult)
    func appendToTokens(_ token: SwiftACMarkDownHtmlGenerator)
    func appendToLookUpTable(_ token: SwiftACMarkDownEmphasisHtmlGenerator)
    func addNewTokenToParsedResult(_ ch: Int)
    func addNewTokenToParsedResult(_ word: String)
    func addNewLineTokenToParsedResult(_ ch: Character)
    func popFront()
    func popBack()
    func clear()
    func hasHtmlTags() -> Bool
    func foundHtmlTags()
    func getIsCaptured() -> Bool
    func setIsCaptured(_ val: Bool)
}

// Implementation for MarkDownParsedResult
class SwiftACMarkDownParsedResult: SwiftACMarkDownParsedResultProtocol {
    private var codeGenTokens: [SwiftACMarkDownHtmlGenerator] = []
    private var emphasisLookUpTable: [SwiftACMarkDownEmphasisHtmlGenerator] = []
    private var isHTMLTagsAdded: Bool = false
    private var isCaptured: Bool = false
    
    func translate() {
        matchLeftAndRightEmphasises()
    }
    
    func addBlockTags() {
        if let firstToken = codeGenTokens.first as? SwiftACMarkDownHtmlGenerator {
            var tokenFirst = firstToken
            tokenFirst.makeItHead()
        }
        if let last = codeGenTokens.last as? SwiftACMarkDownHtmlGenerator {
            var lastToken = last
            lastToken.makeItTail()
        }
    }
    
    func generateHtmlString() -> String {
        return codeGenTokens.map { $0.generateHtmlString() }.joined()
    }
    
    func appendParseResult(_ result: SwiftACMarkDownParsedResult) {
        if !codeGenTokens.isEmpty && !result.codeGenTokens.isEmpty {
            markTags(result.codeGenTokens.first!)
        }
        codeGenTokens.append(contentsOf: result.codeGenTokens)
        emphasisLookUpTable.append(contentsOf: result.emphasisLookUpTable)
        isHTMLTagsAdded = isHTMLTagsAdded || result.hasHtmlTags()
        setIsCaptured(result.getIsCaptured())
    }
    
    func appendToTokens(_ token: SwiftACMarkDownHtmlGenerator) {
        if !codeGenTokens.isEmpty {
            markTags(token)
        }
        codeGenTokens.append(token)
    }
    
    func appendToLookUpTable(_ token: SwiftACMarkDownEmphasisHtmlGenerator) {
        emphasisLookUpTable.append(token)
    }
    
    func addNewTokenToParsedResult(_ ch: Int) {
        let stringToken = String(UnicodeScalar(ch)!)
        let htmlToken = SwiftACMarkDownStringHtmlGenerator(token: stringToken)
        appendToTokens(htmlToken)
    }
    
    func addNewTokenToParsedResult(_ word: String) {
        let htmlToken = SwiftACMarkDownStringHtmlGenerator(token: word)
        appendToTokens(htmlToken)
    }
    
    func addNewLineTokenToParsedResult(_ ch: Character) {
        let htmlToken = SwiftACMarkDownNewLineHtmlGenerator(token: String(ch))
        appendToTokens(htmlToken)
    }
    
    func popFront() {
        codeGenTokens.removeFirst()
    }
    
    func popBack() {
        codeGenTokens.removeLast()
    }
    
    func clear() {
        codeGenTokens.removeAll()
        emphasisLookUpTable.removeAll()
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
    
    private func markTags(_ token: SwiftACMarkDownHtmlGenerator) {
        if codeGenTokens.last?.getBlockType() != token.getBlockType() {
            if codeGenTokens.last?.isNewLine() == true {
                codeGenTokens.removeLast()
            }
            if !codeGenTokens.isEmpty {
                var last = codeGenTokens.last
                last?.makeItTail()
            }
            var mToken = token
            mToken.makeItHead()
        }
    }
    
    private func matchLeftAndRightEmphasises() {
        var leftEmphasisToExplore: [SwiftACMarkDownEmphasisHtmlGenerator] = []
        var currentEmphasis = emphasisLookUpTable.makeIterator()
        while let emphasis = currentEmphasis.next() {
            if emphasis.isLeftEmphasis() || (emphasis.isLeftAndRightEmphasis() && leftEmphasisToExplore.isEmpty) {
                if emphasis.isLeftAndRightEmphasis() && emphasis.isRightEmphasis() {
                    emphasis.changeDirectionToLeft()
                }
                leftEmphasisToExplore.append(emphasis)
            } else if !leftEmphasisToExplore.isEmpty {
                var currentLeftEmphasis = leftEmphasisToExplore.last!
                if !currentLeftEmphasis.isMatch(emphasis) {
                    var store: [SwiftACMarkDownEmphasisHtmlGenerator] = []
                    var isFound = false
                    while !leftEmphasisToExplore.isEmpty && !isFound {
                        let leftToken = leftEmphasisToExplore.removeLast()
                        if leftToken.isMatch(emphasis) {
                            currentLeftEmphasis = leftToken
                            isFound = true
                        } else {
                            store.append(leftToken)
                        }
                    }
                    if !isFound {
                        while !isFound && !store.isEmpty {
                            leftEmphasisToExplore.append(store.removeLast())
                        }
                        if leftEmphasisToExplore.last!.isSameType(emphasis) {
                            emphasis.changeDirectionToLeft()
                        } else {
                            continue
                        }
                        continue
                    }
                }
                var inoutEmphasis = emphasis
                isHTMLTagsAdded = currentLeftEmphasis.generateTags(&inoutEmphasis) || isHTMLTagsAdded
                if inoutEmphasis.isDone() {
                    continue
                }
                if currentLeftEmphasis.isDone() {
                    leftEmphasisToExplore.removeLast()
                }
            }
        }
    }
}

enum SwiftACDelimiterType {
    case initType
    case alphanumeric
    case punctuation
    case escape
    case whiteSpace
    case underscore
    case asterisk
}
