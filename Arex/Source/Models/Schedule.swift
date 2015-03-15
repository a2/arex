import Foundation

struct Weekdays: RawOptionSetType {
    typealias RawValue = UInt
    private let value: UInt
    init(_ value: UInt) { self.value = value }
    init(rawValue value: UInt) { self.value = value }
    init(nilLiteral: ()) { self.value = 0 }
    static var allZeros: Weekdays { return self(0) }
    static func fromMask(raw: UInt) -> Weekdays { return self(raw) }
    var rawValue: UInt { return value }
}

enum Repeat: Equatable {
    case Interval(repeat: Int, calendarUnit: NSCalendarUnit)
    case Weekly(weekdays: Weekdays)
    case MonthlyByDay(day: Int)
    case MonthlyByWeek(week: Int, day: Int)
}

func ==(lhs: Repeat, rhs: Repeat) -> Bool {
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

enum Schedule: Equatable {
    case Repeating(repeat: Repeat, time: Time)
    case Once(fireDate: NSDate, timeZone: NSTimeZone)
}

func ==(lhs: Schedule, rhs: Schedule) -> Bool {
    switch (lhs, rhs) {
    case let (.Repeating(repeat: lhr, time: lht), .Repeating(repeat: rhr, time: rht)):
        return lhr == rhr && lht == rht
    case let (.Once(fireDate: lhd, timeZone: lht), .Once(fireDate: rhd, timeZone: rht)):
        return lhd == rhd && lht == rht
    default:
        return false
    }
}
