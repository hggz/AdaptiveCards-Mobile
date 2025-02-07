import Foundation

class DateTimePreparser {
    private var textTokenCollection: [DateTimePreparsedToken] = []
    private var hasDateTokens: Bool = false

    init() {}

    init(input: String) {
        parseDateTime(input)
    }

    func getTextTokens() -> [DateTimePreparsedToken] {
        return textTokenCollection
    }

    private func addTextToken(_ text: String, format: DateTimePreparsedTokenFormat) {
        guard !text.isEmpty else { return }
        textTokenCollection.append(DateTimePreparsedToken(text: text, format: format))
    }

    private func addDateToken(_ text: String, date: Date, format: DateTimePreparsedTokenFormat) {
        textTokenCollection.append(DateTimePreparsedToken(text: text, date: date, format: format))
        hasDateTokens = true
    }

    private func concatenate() -> String {
        return textTokenCollection.map { $0.text }.joined()
    }

    private func parseDateTime(_ input: String) {
        let pattern = "\\{\\{(DATE|TIME)\\((\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})(Z|([+-])(\\d{2}):(\\d{2}))((, ?SHORT)|(, ?LONG)|(, ?COMPACT))?\\)\\}\\}"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        var text = input
        while let match = regex?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.count)) {
            let nsText = text as NSString
            let fullMatch = nsText.substring(with: match.range)

            let year = Int(nsText.substring(with: match.range(at: 2))) ?? 0
            let month = Int(nsText.substring(with: match.range(at: 3))) ?? 0
            let day = Int(nsText.substring(with: match.range(at: 4))) ?? 0
            let hour = Int(nsText.substring(with: match.range(at: 5))) ?? 0
            let minute = Int(nsText.substring(with: match.range(at: 6))) ?? 0
            let second = Int(nsText.substring(with: match.range(at: 7))) ?? 0

            let formatString = match.range(at: 12).location != NSNotFound ? nsText.substring(with: match.range(at: 12)).trimmingCharacters(in: .whitespaces) : nil
            let format: DateTimePreparsedTokenFormat = {
                switch formatString {
                case "SHORT": return .dateShort
                case "LONG": return .dateLong
                case "COMPACT": return .dateCompact
                default: return .dateCompact
                }
            }()

            if let parsedDate = createDate(year: year, month: month, day: day, hour: hour, minute: minute, second: second) {
                addDateToken(fullMatch, date: parsedDate, format: format)
            } else {
                addTextToken(fullMatch, format: .regularString)
            }

            text = nsText.replacingCharacters(in: match.range, with: "")
        }

        if !text.isEmpty {
            addTextToken(text, format: .regularString)
        }
    }

    private func createDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        return Calendar.current.date(from: dateComponents)
    }

    static func tryParseSimpleTime(_ string: String) -> (hours: Int, minutes: Int)? {
        let pattern = #"^(\d{2}):(\d{2})$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        if let match = regex?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)) {
            let nsString = string as NSString
            let hours = Int(nsString.substring(with: match.range(at: 1))) ?? 0
            let minutes = Int(nsString.substring(with: match.range(at: 2))) ?? 0

            if isValidTime(hours: hours, minutes: minutes) {
                return (hours, minutes)
            }
        }
        return nil
    }

    static func tryParseSimpleDate(_ string: String) -> (year: Int, month: Int, day: Int)? {
        let pattern = #"^(\d{4})-(\d{2})-(\d{2})$"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])

        if let match = regex?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)) {
            let nsString = string as NSString
            let year = Int(nsString.substring(with: match.range(at: 1))) ?? 0
            let month = Int(nsString.substring(with: match.range(at: 2))) ?? 0
            let day = Int(nsString.substring(with: match.range(at: 3))) ?? 0

            if isValidDate(year: year, month: month, day: day) {
                return (year, month, day)
            }
        }
        return nil
    }

    private static func isValidDate(year: Int, month: Int, day: Int) -> Bool {
        guard month > 0 && month <= 12 && day > 0 && day <= 31 else { return false }
        if [4, 6, 9, 11].contains(month) { return day <= 30 }
        if month == 2 {
            return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) ? day <= 29 : day <= 28
        }
        return true
    }

    private static func isValidTime(hours: Int, minutes: Int) -> Bool {
        return hours < 24 && minutes < 60
    }
}
