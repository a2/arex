import Foundation
import LlamaKit
import MessagePack_swift
import Pistachio

public struct ScheduleAdapter: Adapter {
    public func encode(model: Schedule) -> Result<MessagePackValue, NSError> {
        switch model {
        case .Daily:
            return success([
                "type": "daily",
            ])
        case let .EveryXDays(interval: interval, startDate: startDate):
            return success([
                "type": "everyXDays",
                "interval": .Int(numericCast(interval)),
                "startDate": .Double(startDate.timeIntervalSince1970),
            ])
        case let .Weekly(days: days):
            return success([
                "type": "weekly",
                "days": .Int(numericCast(days)),
            ])
        case let .Monthly(days: days):
            return success([
                "type": "monthly",
                "days": .Int(numericCast(days)),
            ])
        }
    }

    public func decode(data: MessagePackValue) -> Result<Schedule, NSError> {
        if let dictionary = data.dictionaryValue {
            switch dictionary["type"]?.stringValue {
            case .Some("daily"):
                return success(.Daily)
            case .Some("everyXDays"):
                if let interval = dictionary["interval"]?.integerValue, startDateInterval = dictionary["startDate"]?.doubleValue {
                    let startDate = NSDate(timeIntervalSince1970: startDateInterval)
                    return success(.EveryXDays(interval: numericCast(interval), startDate: startDate))
                } else {
                    return failure("Expected \"interval\" (Int) and \"startDate\" (Double) in data for Schedule.EveryXDays, got: \(dictionary.keys.map(toString))")
                }
            case .Some("weekly"):
                if let days = dictionary["days"]?.integerValue {
                    return success(.Weekly(days: numericCast(days)))
                } else {
                    return failure("Expected \"days\" (Int) in data for Schedule.Weekly, got: \(dictionary.keys.map(toString))")
                }
            case .Some("monthly"):
                if let days = dictionary["days"]?.integerValue {
                    return success(.Monthly(days: numericCast(days)))
                } else {
                    return failure("Expected \"days\" (Int) in data for Schedule.Monthly, got: \(dictionary.keys.map(toString))")
                }
            default:
                let type = dictionary["type"]
                return failure("Expected one of \"daily\", \"everyXDays\", \"weekly\", \"monthly\" as \"type\" in Schedule data, got: \(type)")
            }
        } else {
            return failure("Expected MessagePackValue.Map, got: \(data)")
        }
    }

    public func decode(model: Schedule, from data: MessagePackValue) -> Result<Schedule, NSError> {
        return decode(data)
    }
}

public struct Adapters {
    private static let dictionaryTransformer: ValueTransformer<[String : MessagePackValue], MessagePackValue, NSError> = {
        let transformClosure: [String : MessagePackValue] -> Result<MessagePackValue, NSError> = { dictionary in
            var messagePackDict = [MessagePackValue : MessagePackValue]()
            for (key, value) in dictionary {
                messagePackDict[.String(key)] = value
            }

            return MessagePackValueTransformers.map.transformedValue(messagePackDict)
        }

        let reverseTransformClosure: MessagePackValue -> Result<[String : MessagePackValue], NSError> = { value in
            return MessagePackValueTransformers.map.reverseTransformedValue(value).flatMap { dictionary in
                var stringDict = [String : MessagePackValue]()
                for (key, value) in dictionary {
                    if let string = key.stringValue {
                        stringDict[string] = value
                    } else {
                        return failure()
                    }
                }

                return success(stringDict)
            }
        }

        return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
    }()

    public static let medication: DictionaryAdapter<Medication, MessagePackValue, NSError> = {
        let lastFilledDate = transform(transform(MedicationLenses.lastFilledDate, lift(DateTransformers.timeIntervalSince1970(), 0.0)), MessagePackValueTransformers.double)
        let schedule = messagePackMap(MedicationLenses.schedule, defaultTransformedValue: .Nil)(adapter: Adapters.schedule, model: Schedule.Daily)
        let times = messagePackArray(MedicationLenses.times)(adapter: Adapters.time, model: Time(hour: 0, minute: 0))
        
        return DictionaryAdapter(specification: [
            "doctorRecordID": messagePackInt(MedicationLenses.doctorRecordID, defaultTransformedValue: .Nil),
            "dosesLeft": messagePackInt(MedicationLenses.dosesLeft, defaultTransformedValue: .Nil),
            "lastFilledDate": lastFilledDate,
            "name": messagePackString(MedicationLenses.name, defaultTransformedValue: .Nil),
            "note": messagePackString(MedicationLenses.note, defaultTransformedValue: .Nil),
            "pharmacyRecordID": messagePackInt(MedicationLenses.pharmacyRecordID, defaultTransformedValue: .Nil),
            "pictureData": messagePackBinary(MedicationLenses.pictureData, defaultTransformedValue: .Nil),
            "schedule": schedule,
            "strength": messagePackString(MedicationLenses.strength, defaultTransformedValue: .Nil),
            "times": times,
        ], dictionaryTansformer: dictionaryTransformer)
    }()

    public static let schedule = ScheduleAdapter()

    public static let time = DictionaryAdapter(specification: [
        "hour": messagePackInt(TimeLenses.hour),
        "minute": messagePackInt(TimeLenses.minute),
    ], dictionaryTansformer: dictionaryTransformer)
}
