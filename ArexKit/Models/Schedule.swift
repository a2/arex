public enum Schedule {
    case Daily
    case EveryXDays(interval: Int, startDate: NSDate)
    case Weekly(days: Int)
    case Monthly(days: Int)
    case NotCurrentlyTaken
}

// MARK: - CustomStringConvertible

extension Schedule: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Daily:
            return "Daily"
        case let .EveryXDays(interval: interval, startDate: startDate):
            return "EveryXDays(interval: \(interval), startDate: \(startDate))"
        case let .Weekly(days: days):
            return "Weekly(days: 0b\(String(days, radix: 2)))"
        case let .Monthly(days: days):
            return "Monthly(days: 0b\(String(days, radix: 2)))"
        case .NotCurrentlyTaken:
            return "NotCurrentlyTaken"
        }
    }
}

// MARK: - Equatable

extension Schedule: Equatable {}

public func ==(lhs: Schedule, rhs: Schedule) -> Bool {
    switch (lhs, rhs) {
    case (.Daily, .Daily), (.NotCurrentlyTaken, .NotCurrentlyTaken):
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
