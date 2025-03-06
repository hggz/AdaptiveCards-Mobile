import Foundation

public enum DateTimePreparsedTokenFormat: Equatable, Codable {
    case RegularString
    case DateCompact
    case DateShort
    case DateLong
}

public class SwiftDateTimePreparsedToken: Codable {
    public let text: String
    public let format: DateTimePreparsedTokenFormat
    private var dateValue: Date?

    public init(text: String, format: DateTimePreparsedTokenFormat) {
        self.text = text
        self.format = format
    }
    
    public init(text: String, date: Date, format: DateTimePreparsedTokenFormat) {
        self.text = text
        self.dateValue = date
        self.format = format
    }
    
    /// Returns the day component if a date was parsed; otherwise 0.
    public var day: Int {
        guard let date = dateValue else { return 0 }
        return Calendar.current.component(.day, from: date)
    }
    
    /// Returns the month component (zero-indexed to match C++ tests).
    public var month: Int {
        guard let date = dateValue else { return 0 }
        // Calendar gives 1 for January, so subtract 1.
        return Calendar.current.component(.month, from: date) - 1
    }
    
    /// Returns the year component.
    public var year: Int {
        guard let date = dateValue else { return 0 }
        return Calendar.current.component(.year, from: date)
    }
}
