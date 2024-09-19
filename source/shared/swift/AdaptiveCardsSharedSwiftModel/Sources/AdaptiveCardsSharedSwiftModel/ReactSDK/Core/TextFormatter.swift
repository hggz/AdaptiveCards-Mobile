import Foundation

protocol AbstractTextFormatter {
    var regularExpression: NSRegularExpression { get }
    
    func internalFormat(lang: String?, matches: [String]) -> String
    func format(lang: String?, input: String?) -> String?
}

extension AbstractTextFormatter {
    func format(lang: String?, input: String?) -> String? {
        guard let input = input else { return nil }
        
        var result = input
        let matches = regularExpression.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        for match in matches {
            let range = match.range(at: 0)
            let matchedString = (input as NSString).substring(with: range)
            
            var subMatches: [String] = []
            for i in 1..<match.numberOfRanges {
                subMatches.append((input as NSString).substring(with: match.range(at: i)))
            }
            
            result = result.replacingOccurrences(of: matchedString, with: internalFormat(lang: lang, matches: subMatches))
        }
        
        return result
    }
}

class SwiftDateFormatter: AbstractTextFormatter {
    let regularExpression = try! NSRegularExpression(pattern: "\\{{2}DATE\\((\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:Z|(?:(?:-|\\+)\\d{2}:\\d{2})))(?:, ?(COMPACT|LONG|SHORT))?\\)\\}{2}", options: [])
    
    func internalFormat(lang: String?, matches: [String]) -> String {
        let date = ISO8601DateFormatter().date(from: matches[0])!
        let format = matches.count > 1 ? matches[1].lowercased() : "compact"
        
        if format != "compact" {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: lang ?? "")
            dateFormatter.dateStyle = format == "short" ? .short : (format == "long" ? .long : .medium)
            return dateFormatter.string(from: date)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            return dateFormatter.string(from: date)
        }
    }
}

class TimeFormatter: AbstractTextFormatter {
    let regularExpression = try! NSRegularExpression(pattern: "\\{{2}TIME\\((\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:Z|(?:(?:-|\\+)\\d{2}:\\d{2})))\\)\\}{2}", options: [])
    
    func internalFormat(lang: String?, matches: [String]) -> String {
        let date = ISO8601DateFormatter().date(from: matches[0])!
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: lang ?? "")
        return dateFormatter.string(from: date)
    }
}

func formatText(lang: String?, text: String?) -> String? {
    let formatters: [AbstractTextFormatter] = [SwiftDateFormatter(), TimeFormatter()]
    
    var result = text
    for formatter in formatters {
        result = formatter.format(lang: lang, input: result)
    }
    
    return result
}
