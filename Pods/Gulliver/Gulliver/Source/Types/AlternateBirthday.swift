import AddressBook

public struct AlternateBirthday: RawRepresentable {
    public var calendarIdentifier: String
    public var era: Int
    public var year: Int
    public var month: Int
    public var day: Int
    public var isLeapMonth: Bool

    public var calendar: NSCalendar {
        get {
            return NSCalendar(calendarIdentifier: calendarIdentifier)!
        }
        set {
            calendarIdentifier = newValue.calendarIdentifier
        }
    }

    public var dateComponents: NSDateComponents {
        let dateComponents = NSDateComponents()
        dateComponents.calendar = NSCalendar(calendarIdentifier: calendarIdentifier)
        dateComponents.era = era
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.leapMonth = isLeapMonth
        return dateComponents
    }

    public init(calendarIdentifier: String, era: Int, year: Int, month: Int, day: Int, isLeapMonth: Bool) {
        self.calendarIdentifier = calendarIdentifier
        self.era = era
        self.year = year
        self.month = month
        self.day = day
        self.isLeapMonth = isLeapMonth
    }

    public init?(dateComponents: NSDateComponents) {
        if let calendarIdentifier = dateComponents.calendar?.calendarIdentifier {
            let day = dateComponents.day
            let era = dateComponents.era
            let month = dateComponents.month
            let year = dateComponents.year

            let undefined: Int = numericCast(NSDateComponentUndefined)
            if day == undefined || era == undefined || month == undefined || year == undefined {
                return nil
            } else {
                self.init(calendarIdentifier: calendarIdentifier, era: era, year: year, month: month, day: day, isLeapMonth: dateComponents.leapMonth)
            }
        } else {
            return nil
        }
    }

    public var rawValue: [NSObject : AnyObject] {
        return [
            kABPersonAlternateBirthdayCalendarIdentifierKey as String: calendarIdentifier,
            kABPersonAlternateBirthdayDayKey as String: day,
            kABPersonAlternateBirthdayEraKey as String: era,
            kABPersonAlternateBirthdayIsLeapMonthKey as String: isLeapMonth,
            kABPersonAlternateBirthdayMonthKey as String: month,
            kABPersonAlternateBirthdayYearKey as String: year,
        ]
    }

    public init?(rawValue: [NSObject : AnyObject]) {
        if let calendarIdentifier = rawValue[kABPersonAlternateBirthdayCalendarIdentifierKey as String] as? String,
            day = rawValue[kABPersonAlternateBirthdayDayKey as String] as? Int,
            era = rawValue[kABPersonAlternateBirthdayEraKey as String] as? Int,
            isLeapMonth = rawValue[kABPersonAlternateBirthdayIsLeapMonthKey as String] as? Bool,
            month = rawValue[kABPersonAlternateBirthdayMonthKey as String] as? Int,
            year = rawValue[kABPersonAlternateBirthdayYearKey as String] as? Int {
                self.init(calendarIdentifier: calendarIdentifier, era: era, year: year, month: month, day: day, isLeapMonth: isLeapMonth)
        } else {
            return nil
        }
    }
}
