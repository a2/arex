import Foundation

public struct Weekdays: RawOptionSetType {
    typealias RawValue = UInt
    private let value: UInt
    init(_ value: UInt) { self.value = value }
    public init(rawValue value: UInt) { self.value = value }
    public init(nilLiteral: ()) { self.value = 0 }
    public static var allZeros: Weekdays { return self(0) }
    static func fromMask(raw: UInt) -> Weekdays { return self(raw) }
    public var rawValue: UInt { return value }
}

public enum Repeat: Equatable, Printable {
    case Interval(repeat: Int, calendarUnit: NSCalendarUnit)
    case Weekly(weekdays: Weekdays)
    case MonthlyByDay(day: Int)
    case MonthlyByWeek(week: Int, day: Int)

    public var description: String {
        switch self {
        case let .Interval(repeat: repeat, calendarUnit: calendarUnit):
            return "<Repeat.Interval: repeat=\(repeat); calendarUnit=\(calendarUnit)>"
        case let .Weekly(weekdays: weekdays):
            return "<Repeat.Weekly: weekdays=\(weekdays)>"
        case let .MonthlyByDay(day: day):
            return "<Repeat.MonthlyByDay: day=\(day)>"
        case let .MonthlyByWeek(week: week, day: day):
            return "<Repeat.MonthlyByWeek: week=\(week); day=\(day)>"
        }
    }
}

public func ==(lhs: Repeat, rhs: Repeat) -> Bool {
    switch (lhs, rhs) {
    case let (.Interval(repeat: lhr, calendarUnit: lhu), .Interval(repeat: rhr, calendarUnit: rhu)):
        return lhr == rhr && lhu == rhu
    case let (.Weekly(weekdays: lhw), .Weekly(weekdays: rhw)):
        return lhw == rhw
    case let (.MonthlyByDay(day: lhd), .MonthlyByDay(day: rhd)):
        return lhd == rhd
    case let (.MonthlyByWeek(week: lhw, day: lhd), .MonthlyByWeek(week: rhw, day: rhd)):
        return lhw == rhw && lhd == rhd
    default:
        return false
    }
}

public enum Schedule: Equatable, Printable {
    case Repeating(repeat: Repeat, time: Time)
    case Once(fireDate: NSDate, timeZone: NSTimeZone)

    public var description: String {
        switch self {
        case let .Repeating(repeat: repeat, time: time):
            return "<Schedule.Repeating: repeat=\(repeat); time=\(time)>"
        case let .Once(fireDate: fireDate, timeZone: timeZone):
            return "<Schedule.Once: fireDate=\(fireDate); timeZone=\(timeZone.name)>"
        }
    }
}

public func ==(lhs: Schedule, rhs: Schedule) -> Bool {
    switch (lhs, rhs) {
    case let (.Repeating(repeat: lhr, time: lht), .Repeating(repeat: rhr, time: rht)):
        return lhr == rhr && lht == rht
    case let (.Once(fireDate: lhd, timeZone: lht), .Once(fireDate: rhd, timeZone: rht)):
        let datesEqual = abs(lhd.timeIntervalSinceDate(rhd)) < 1.0
        return datesEqual && lht == rht
    default:
        return false
    }
}
