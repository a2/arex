import Foundation
import LlamaKit
import MessagePack_swift
import Pistachio

struct RepeatAdapter: Adapter {
    func encode(model: Repeat) -> Result<MessagePackValue, NSError> {
        switch model {
        case let .Interval(repeat: repeat, calendarUnit: calendarUnit):
            return success([
                "type": "interval",
                "repeat": .Int(numericCast(repeat)),
                "calendarUnit": .UInt(numericCast(calendarUnit.rawValue)),
            ])
        case let .MonthlyByDay(day: day):
            return success([
                "type": "monthly",
                "day": .Int(numericCast(day)),
            ])
        case let .MonthlyByWeek(week: week, day: day):
            return success([
                "type": "monthly",
                "week": .Int(numericCast(day)),
                "day": .Int(numericCast(day)),
            ])
        case let .Weekly(weekdays: weekdays):
            return success([
                "type": "weekly",
                "weekdays": .UInt(numericCast(weekdays.rawValue)),
            ])
        }
    }

    func decode(data: MessagePackValue) -> Result<Repeat, NSError> {
        if let dictionary = data.dictionaryValue {
            let value = dictionary["type"]
            switch value?.stringValue {
            case .Some("interval"):
                switch (dictionary["repeat"]?.integerValue, dictionary["calendarUnit"]?.unsignedIntegerValue) {
                case let (.Some(repeat), .Some(calendarUnit)):
                    return success(.Interval(repeat: numericCast(repeat), calendarUnit: NSCalendarUnit(rawValue: numericCast(calendarUnit))))
                default:
                    return failure("Expected \"repeat\" (Int) and  \"calendarUnit\" (UInt) in data for Repeat.Interval, got: \(dictionary.keys.map(toString))")
                }
            case .Some("monthly"):
                switch (dictionary["week"]?.integerValue, dictionary["day"]?.integerValue) {
                case let (.Some(week), .Some(day)):
                    return success(.MonthlyByWeek(week: numericCast(week), day: numericCast(day)))
                case let (.None, .Some(day)):
                    return success(.MonthlyByDay(day: numericCast(day)))
                default:
                    return failure("Expected \"day\" (Int) and \"week\" (Int?) in data for Repeat.Monthly(ByDay|ByWeek), got: \(dictionary.keys.map(toString))")
                }
            case .Some("weekly"):
                switch dictionary["weekdays"]?.unsignedIntegerValue {
                case let .Some(weekdays):
                    return success(.Weekly(weekdays: Weekdays(rawValue: numericCast(weekdays))))
                default:
                    return failure("Expected \"weekdays\" (UInt) in data for Repeat.Weekdays, got: \(dictionary.keys.map(toString))")
                }
            default:
                return failure("Expected one of \"interval\", \"monthly\", \"weekly\" in \"type\" for Repeat, got: \(value)")
            }
        } else {
            return failure("Expected MessagePackValue.Map, got: \(data)")
        }
    }

    func decode(model: Repeat, from data: MessagePackValue) -> Result<Repeat, NSError> {
        return decode(data)
    }
}

struct ScheduleAdapter: Adapter {
    func encode(model: Schedule) -> Result<MessagePackValue, NSError> {
        switch model {
        case let .Repeating(repeat: repeat, time: time):
            switch (Adapters.repeat.encode(repeat), Adapters.time.encode(time)) {
            case let (.Success(repeatBox), .Success(timeBox)):
                return success([
                    "type": "repeating",
                    "repeat": repeatBox.unbox,
                    "time": timeBox.unbox,
                ])
            default:
                return failure("Unexpected failure when encoding repeat and/or time for Schedule.Repeating")
            }
        case let .Once(fireDate: fireDate, timeZone: timeZone):
            return success([
                "type": "once",
                "fireDate": .Double(fireDate.timeIntervalSince1970),
                "timeZone": .String(timeZone.name),
            ])
        default:
            return failure("Unknown schedule type \(model)")
        }
    }

    func decode(data: MessagePackValue) -> Result<Schedule, NSError> {
        if let dictionary = data.dictionaryValue {
            let value = dictionary["type"]
            switch value?.stringValue {
            case .Some("repeating"):
                switch (dictionary["repeat"], dictionary["time"]) {
                case let (.Some(repeat), .Some(time)):
                    let repeatResult = Adapters.repeat.decode(Repeat.Interval(repeat: 0,calendarUnit: nil), from: repeat)
                    let timeResult = Adapters.time.decode(Time(hour: 0, minute: 0), from: time)
                    switch (repeatResult, timeResult) {
                    case let (.Success(repeatBox), .Success(timeBox)):
                        return success(.Repeating(repeat: repeatBox.unbox, time: timeBox.unbox))
                    default:
                        return failure("Unexpected failure when decoding repeat and/or time for Schedule.Repeating")
                    }
                default:
                    return failure("Expected \"repeat\" (Map) and \"time\" (Map) in data for Schedule.Repeating, got: \(dictionary.keys.map(toString))")
                }
            case .Some("once"):
                switch (dictionary["fireDate"]?.doubleValue, dictionary["timeZone"]?.stringValue) {
                case let (.Some(fireDateTimeIntervalSince1970), .Some(timeZoneName)):
                    let fireDate = NSDate(timeIntervalSince1970: fireDateTimeIntervalSince1970)
                    if let timeZone = NSTimeZone(name: timeZoneName) {
                        return success(.Once(fireDate: fireDate, timeZone: timeZone))
                    } else {
                        return failure("Unexpected \"timeZone\" in data for Schedule.Once, got: \(timeZoneName)")
                    }
                default:
                    return failure("Expected")
                }
            default:
                return failure("Expected one of \"repeating\", \"once\" in \"type\" for Schedule data, got: \(value)")
            }
        } else {
            return failure("Expected MessagePackValue.Map, got: \(data)")
        }
    }

    func decode(model: Schedule, from data: MessagePackValue) -> Result<Schedule, NSError> {
        return decode(data)
    }
}

struct Adapters {
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

    static let medication: DictionaryAdapter<Medication, MessagePackValue, NSError> = {
        let lastFilledDate = transform(transform(MedicationLenses.lastFilledDate, lift(DateTransformers.timeIntervalSince1970(), 0.0)), MessagePackValueTransformers.double)
        let schedules = messagePackArray(MedicationLenses.schedules)(adapter: Adapters.schedule, model: Schedule.Once(fireDate: NSDate(), timeZone: NSTimeZone()))

        return DictionaryAdapter(specification: [
            "doctorRecordID": messagePackInt(MedicationLenses.doctorRecordID, defaultTransformedValue: .Nil),
            "dosesLeft": messagePackInt(MedicationLenses.dosesLeft, defaultTransformedValue: .Nil),
            "lastFilledDate": lastFilledDate,
            "name": messagePackString(MedicationLenses.name, defaultTransformedValue: .Nil),
            "note": messagePackString(MedicationLenses.note, defaultTransformedValue: .Nil),
            "pharmacyRecordID": messagePackInt(MedicationLenses.pharmacyRecordID, defaultTransformedValue: .Nil),
            "pictureData": messagePackBinary(MedicationLenses.pictureData, defaultTransformedValue: .Nil),
            "schedules": schedules,
            "strength": messagePackString(MedicationLenses.strength, defaultTransformedValue: .Nil),
        ], dictionaryTansformer: dictionaryTransformer)
    }()

    static let repeat = RepeatAdapter()

    static let schedule = ScheduleAdapter()

    static let time = DictionaryAdapter(specification: [
        "hour": messagePackInt(TimeLenses.hour),
        "minute": messagePackInt(TimeLenses.minute),
    ], dictionaryTansformer: dictionaryTransformer)
}
