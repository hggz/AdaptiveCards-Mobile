import Foundation

enum DateTimePreparsedTokenFormat: String, Codable {
    case regularString
}

struct DateTimePreparsedToken: Codable {
    var text: String
    var date: Date
    var format: DateTimePreparsedTokenFormat

    init(text: String = "", date: Date = Date(), format: DateTimePreparsedTokenFormat = .regularString) {
        self.text = text
        self.date = date
        self.format = format
    }

    var day: Int {
        return Calendar.current.component(.day, from: date)
    }

    var month: Int {
        return Calendar.current.component(.month, from: date) - 1 // Adjusting to match C++ (0-11)
    }

    var year: Int {
        return Calendar.current.component(.year, from: date)
    }
}
