import Foundation

public enum Schedule: Equatable, Printable {
    case Daily
    case EveryXDays(interval: Int, startDate: NSDate)
    case Weekly(days: Int)
    case Monthly(days: Int)

    public var description: String {
        switch self {
        case .Daily:
            return "Daily"
        case let .EveryXDays(interval: interval, startDate: startDate):
            return "EveryXDays(interval: \(interval), startDate: \(startDate))"
        case let .Weekly(days: days):
            return "Weekly(days: \(days))"
        case let .Monthly(days: days):
            return "Monthly(days: \(days))"
        }
    }
}

public func ==(lhs: Schedule, rhs: Schedule) -> Bool {
    switch (lhs, rhs) {
    case (.Daily, .Daily):
        return true
    case let (.EveryXDays(interval: leftInterval, startDate: leftStartDate), .EveryXDays(interval: rightInterval, startDate: rightStartDate)):
        return leftInterval == rightInterval && abs(leftStartDate.timeIntervalSinceDate(rightStartDate)) < 1.0
    case let (.Weekly(days: leftDays), .Weekly(days: rightDays)):
        return leftDays == rightDays
    case let (.Monthly(days: leftDays), .Monthly(days: rightDays)):
        return leftDays == rightDays
    default:
        return false
    }
}
