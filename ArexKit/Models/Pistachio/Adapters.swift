import Foundation
import MessagePack
import Monocle
import Pistachio
import ReactiveCocoa
import Result
import ValueTransformer

public enum ScheduleAdapterError: Swift.ErrorType, ErrorRepresentable, ReactiveCocoa.ErrorType {
    public static let domain = "ScheduleAdapterError"

    case InvalidInput(description: String)

    public var code: Int {
        switch self {
        case .InvalidInput:
            return 1
        }
    }

    public var description: String {
        switch self {
        case .InvalidInput:
            return NSLocalizedString("Unable to reverse transform value.", comment: "")
        }
    }

    public var failureReason: String? {
        switch self {
        case let .InvalidInput(description: description):
            return description
        }
    }

    public var nsError: NSError {
        return error(code: self)
    }
}

private extension ScheduleType {
    enum TypeString: String {
        case Daily = "daily"
        case EveryXDays = "everyXDays"
        case Weekly = "weekly"
        case Monthly = "monthly"
        case NotCurrentlyTaken = "notCurrentlyTaken"
    }

    var typeString: String {
        switch self {
        case .Daily:
            return TypeString.Daily.rawValue
        case .EveryXDays:
            return TypeString.EveryXDays.rawValue
        case .Weekly:
            return TypeString.Weekly.rawValue
        case .Monthly:
            return TypeString.Monthly.rawValue
        case .NotCurrentlyTaken:
            return TypeString.NotCurrentlyTaken.rawValue
        }
    }

    init?(typeString: String) {
        if let enumValue = TypeString(rawValue: typeString) {
            switch enumValue {
            case .Daily:
                self = .Daily
            case .EveryXDays:
                self = .EveryXDays
            case .Weekly:
                self = .Weekly
            case .Monthly:
                self = .Monthly
            case .NotCurrentlyTaken:
                self = .NotCurrentlyTaken
            }
        } else {
            return nil
        }
    }
}

public struct ScheduleAdapter: AdapterType {
    public init() {}

    private func error(string: String) -> NSError {
        return ScheduleAdapterError.InvalidInput(description: string).nsError
    }

    public func transform(model: Schedule) -> Result<MessagePackValue, NSError> {
        var encoded: [MessagePackValue : MessagePackValue] = [
            "type": .String(model.scheduleType.typeString),
        ]

        switch model {
        case .Daily, .NotCurrentlyTaken:
            break
        case let .EveryXDays(interval: interval, startDate: startDate):
            encoded += [
                "interval": .Int(numericCast(interval)),
                "startDate": .Double(startDate.timeIntervalSince1970),
            ]
        case let .Weekly(days: days):
            encoded += ["days": .Int(numericCast(days))]
        case let .Monthly(days: days):
            encoded += ["days": .Int(numericCast(days))]
        }

        return .success(.Map(encoded))
    }

    public func reverseTransform(data: MessagePackValue) -> Result<Schedule, NSError> {
        if let dictionary = data.dictionaryValue,
            typeString = dictionary["type"]?.stringValue,
            scheduleType = ScheduleType(typeString: typeString) {
                switch scheduleType {
                case .Daily:
                    return .success(.Daily)
                case .EveryXDays:
                    if let interval = dictionary["interval"]?.integerValue,
                        startDateInterval = dictionary["startDate"]?.doubleValue {
                            let startDate = NSDate(timeIntervalSince1970: startDateInterval)
                            return .success(.EveryXDays(interval: numericCast(interval), startDate: startDate))
                    } else {
                        let stringKeys = dictionary.keys.map { String($0) }
                        return .failure(error("Expected \"interval\" (Int) and \"startDate\" (Double) in data for Schedule.EveryXDays, got: \(stringKeys)"))
                    }
                case .Weekly:
                    if let days = dictionary["days"]?.integerValue {
                        return .success(.Weekly(days: numericCast(days)))
                    } else {
                        let stringKeys = dictionary.keys.map { String($0) }
                        return .failure(error("Expected \"days\" (Int) in data for Schedule.Weekly, got: \(stringKeys)"))
                    }
                case .Monthly:
                    if let days = dictionary["days"]?.integerValue {
                        return .success(.Monthly(days: numericCast(days)))
                    } else {
                        let stringKeys = dictionary.keys.map { String($0) }
                        return .failure(error("Expected \"days\" (Int) in data for Schedule.Monthly, got: \(stringKeys)"))
                    }
                case .NotCurrentlyTaken:
                    return .success(.NotCurrentlyTaken)
                }
        } else {
            return .failure(error("Expected MessagePackValue.Map with one of \"daily\", \"everyXDays\", \"weekly\", \"monthly\", \"notCurrentlyTaken\" as \"type\" (String) in Schedule data , got: \(data)"))
        }
    }
}

public struct Adapters {
    public static let medication = MessagePackAdapter<Medication>(specification: [
        "name": messagePackString(MedicationLenses.name),
        "schedule": messagePackMap(MedicationLenses.schedule)(adapter: Adapters.schedule),
        "strength": messagePackString(MedicationLenses.strength),
        "times": messagePackArray(MedicationLenses.times)(adapter: Adapters.time),
    ], value: Medication())

    public static let schedule = ScheduleAdapter()

    public static let time = MessagePackAdapter(specification: [
        "hour": messagePackInt(TimeLenses.hour),
        "minute": messagePackInt(TimeLenses.minute),
    ], value: Time())
}
