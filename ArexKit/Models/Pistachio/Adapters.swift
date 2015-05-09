import Foundation
import MessagePack
import Monocle
import Pistachio
import ReactiveCocoa
import Result
import ValueTransformer

public enum ScheduleAdapterError: ErrorRepresentable, ErrorType {
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

public struct ScheduleAdapter: AdapterType {
    private func error(string: String) -> NSError {
        return ScheduleAdapterError.InvalidInput(description: string).nsError
    }

    public func transform(model: Schedule) -> Result<MessagePackValue, NSError> {
        switch model {
        case .Daily:
            return .success([
                "type": "daily",
            ])
        case let .EveryXDays(interval: interval, startDate: startDate):
            return .success([
                "type": "everyXDays",
                "interval": .Int(numericCast(interval)),
                "startDate": .Double(startDate.timeIntervalSince1970),
            ])
        case let .Weekly(days: days):
            return .success([
                "type": "weekly",
                "days": .Int(numericCast(days)),
            ])
        case let .Monthly(days: days):
            return .success([
                "type": "monthly",
                "days": .Int(numericCast(days)),
            ])
        }
    }

    public func reverseTransform(data: MessagePackValue) -> Result<Schedule, NSError> {
        if let dictionary = data.dictionaryValue {
            switch dictionary["type"]?.stringValue {
            case .Some("daily"):
                return .success(.Daily)
            case .Some("everyXDays"):
                if let interval = dictionary["interval"]?.integerValue, startDateInterval = dictionary["startDate"]?.doubleValue {
                    let startDate = NSDate(timeIntervalSince1970: startDateInterval)
                    return .success(.EveryXDays(interval: numericCast(interval), startDate: startDate))
                } else {
                    return .failure(error("Expected \"interval\" (Int) and \"startDate\" (Double) in data for Schedule.EveryXDays, got: \(dictionary.keys.map(toString))"))
                }
            case .Some("weekly"):
                if let days = dictionary["days"]?.integerValue {
                    return .success(.Weekly(days: numericCast(days)))
                } else {
                    return .failure(error("Expected \"days\" (Int) in data for Schedule.Weekly, got: \(dictionary.keys.map(toString))"))
                }
            case .Some("monthly"):
                if let days = dictionary["days"]?.integerValue {
                    return .success(.Monthly(days: numericCast(days)))
                } else {
                    return .failure(error("Expected \"days\" (Int) in data for Schedule.Monthly, got: \(dictionary.keys.map(toString))"))
                }
            default:
                let type = dictionary["type"]
                return .failure(error("Expected one of \"daily\", \"everyXDays\", \"weekly\", \"monthly\" as \"type\" in Schedule data, got: \(type)"))
            }
        } else {
            return .failure(error("Expected MessagePackValue.Map, got: \(data)"))
        }
    }
}

public struct Adapters {
    public static let medication = MessagePackAdapter<Medication>(specification: [
        "name": messagePackString(MedicationLenses.name, defaultTransformedValue: .Nil),
        "pictureData": messagePackBinary(MedicationLenses.pictureData, defaultTransformedValue: .Nil),
        "schedule": messagePackMap(MedicationLenses.schedule, defaultTransformedValue: .Nil)(adapter: Adapters.schedule),
        "strength": messagePackString(MedicationLenses.strength, defaultTransformedValue: .Nil),
        "times": messagePackArray(MedicationLenses.times)(adapter: Adapters.time),
    ], value: Medication())

    public static let schedule = ScheduleAdapter()

    public static let time = MessagePackAdapter(specification: [
        "hour": messagePackInt(TimeLenses.hour),
        "minute": messagePackInt(TimeLenses.minute),
    ], value: Time(hour: 0, minute: 0))
}
