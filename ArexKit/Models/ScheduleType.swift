public enum ScheduleType: Int {
    case Daily
    case EveryXDays
    case Weekly
    case Monthly
    case NotCurrentlyTaken
}

extension ScheduleType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Daily:
            return "Daily"
        case .EveryXDays:
            return "EveryXDays"
        case .Weekly:
            return "Weekly"
        case .Monthly:
            return "Monthly"
        case .NotCurrentlyTaken:
            return "NotCurrentlyTaken"
        }
    }
}

extension Schedule {
    public var scheduleType: ScheduleType {
        switch self {
        case .Daily:
            return .Daily
        case .EveryXDays:
            return .EveryXDays
        case .Weekly:
            return .Weekly
        case .Monthly:
            return .Monthly
        case .NotCurrentlyTaken:
            return .NotCurrentlyTaken
        }
    }
}
