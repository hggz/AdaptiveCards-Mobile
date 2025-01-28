// ACMarkDownParser.swift
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import Foundation

protocol MarkDownParserProtocol {
    func transformToHtml() -> String
    func getRawText() -> String
    func hasHtmlTags() -> Bool
    func isEscaped() -> Bool
}

class MarkDownParser: MarkDownParserProtocol {
    private var m_text: String
    private var m_parsedResult: MarkDownParsedResult
    private var m_hasHTMLTag: Bool
    private var m_isEscaped: Bool

    required init(txt: String) {
        self.m_text = txt
        self.m_parsedResult = MarkDownParsedResult()
        self.m_hasHTMLTag = false
        self.m_isEscaped = false
    }

    // Transforms string to HTML
    func transformToHtml() -> String {
        if m_text.isEmpty {
            return "<p></p>"
        }
        // Begin parsing HTML blocks
        parseBlock()
    
        // Process further what is parsed before outputting HTML string
        m_parsedResult.translate()

        // Add block tags such as <p> <ul>
        m_parsedResult.addBlockTags()

        m_hasHTMLTag = m_parsedResult.hasHtmlTags()
        return m_parsedResult.generateHtmlString()
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

    // MarkDown consists of blocks, this method parses blocks
    private func parseBlock() {
        let stream = escapeText()
        let parser = EmphasisParser()

        for line in stream.split(separator: "\n") {
            var newLine = String(line)
            parser.parseBlock(&newLine)
        }

        print(parser.getParsedResult())
        m_parsedResult.appendParseResult(parser.getParsedResult())
    }

    private func escapeText() -> String {
        var escaped = ""
        var nonEscapedCounts = 0

        for ch in m_text {
            switch ch {
            case "<":
                escaped += "&lt;"
            case ">":
                escaped += "&gt;"
            case "\"":
                escaped += "&quot;"
            case "&":
                escaped += "&amp;"
            default:
                escaped += String(ch)
                nonEscapedCounts += 1
            }
        }

        m_isEscaped = (nonEscapedCounts != m_text.count)
        return escaped
    }
}
