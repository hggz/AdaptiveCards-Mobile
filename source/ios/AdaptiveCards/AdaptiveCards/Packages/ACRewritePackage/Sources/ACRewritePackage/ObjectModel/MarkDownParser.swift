import Foundation

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
