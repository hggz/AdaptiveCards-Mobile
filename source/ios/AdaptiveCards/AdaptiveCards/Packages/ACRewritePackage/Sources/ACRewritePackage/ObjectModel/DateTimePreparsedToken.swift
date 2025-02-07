import Foundation

enum DateTimePreparsedTokenFormat: String, Codable {
    case regularString
    case dateShort
    case dateLong
    case dateCompact
}

struct DateTimePreparsedToken: Codable {
    let text: String
    let date: Date?
    let format: DateTimePreparsedTokenFormat

    init(text: String, date: Date? = nil, format: DateTimePreparsedTokenFormat = .regularString) {
        self.text = text
        self.date = date
        self.format = format
    }

    var day: Int? {
        guard let date = date else { return nil }
        return Calendar.current.component(.day, from: date)
    }

    var month: Int? {
        guard let date = date else { return nil }
        return Calendar.current.component(.month, from: date) - 1 // Adjust to match C++ (0-11)
    }

    var year: Int? {
        guard let date = date else { return nil }
        return Calendar.current.component(.year, from: date)
    }
}
