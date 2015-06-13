import Monocle
import Pistachio

private func makeDateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = .NoStyle
    dateFormatter.formattingContext = .Standalone
    dateFormatter.locale = NSLocale.currentLocale()
    dateFormatter.timeStyle = .ShortStyle
    dateFormatter.timeZone = NSTimeZone(name: "UTC")
    return dateFormatter
}

public class MedicationDetailForm: NSObject, FXForm {
    private class ValueTransformer: NSValueTransformer {
        let dateFormatter: NSDateFormatter

        init(dateFormatter: NSDateFormatter) {
            self.dateFormatter = dateFormatter
        }

        class override func allowsReverseTransformation() -> Bool {
            return true
        }

        override func transformedValue(value: AnyObject?) -> AnyObject? {
            if let date = value as? NSDate {
                return dateFormatter.stringFromDate(date)
            } else if let string = value as? String {
                return string
            } else {
                return nil
            }
        }

        override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
            if let string = value as? String {
                return dateFormatter.dateFromString(string)
            } else if let date = value as? NSDate {
                return date
            } else {
                return nil
            }
        }
    }

    public init(medication: Medication) {
        self.valueTransformer = ValueTransformer(dateFormatter: dateFormatter)

        super.init()
        
        self.medication = medication
    }

    private let dateFormatter: NSDateFormatter = makeDateFormatter()
    private let valueTransformer: ValueTransformer

    public var medication: Medication {
        get {
            func makeSchedule() -> Schedule {
                let enumValue = ScheduleType(rawValue: scheduleType) ?? undefined("Unexpected rawValue \(self.scheduleType) for ScheduleType")
                switch enumValue {
                case .Daily:
                    return .Daily
                case .EveryXDays:
                    return .EveryXDays(interval: daysBetweenDoses, startDate: self.startDate)
                case .Weekly:
                    return .Weekly(days: weeklyDays)
                case .Monthly:
                    return .Monthly(days: monthlyDays)
                case .NotCurrentlyTaken:
                    return .NotCurrentlyTaken
                }
            }

            func makeTimes() -> [Time] {
                let calendar = dateFormatter.calendar
                let dates = times as! [NSDate]
                return dates.map { time in
                    let components = calendar.components([.Hour, .Minute], fromDate: time)
                    return Time(dateComponents: components) ?? undefined("Either .Hour or .Minute component was undefined")
                }
            }

            return Medication(name: name, schedule: makeSchedule(), strength: strength, times: makeTimes(), UUID: UUID)
        }
        set {
            name = get(MedicationLenses.name, newValue)
            strength = get(MedicationLenses.strength, newValue)

            let calendar = dateFormatter.calendar
            times = get(MedicationLenses.times, newValue).map { time in
                return calendar.dateFromComponents(time.dateComponents) ?? undefined("Unable to create date from time \(time)")
            }
            UUID = get(MedicationLenses.UUID, newValue)
        }
    }

    public var UUID = NSUUID()

    public internal(set) var name: String?
    public func nameField() -> [NSObject : AnyObject] {
        return [
            FXFormFieldTitle: NSLocalizedString("Name", comment: "Name of medication; text field prompt"),
            "textField.autocapitalizationType": UITextAutocapitalizationType.Words.rawValue,
        ]
    }

    public internal(set) var strength: String?
    public func strengthField() -> [NSObject : AnyObject] {
        return [
            FXFormFieldTitle: NSLocalizedString("Strength", comment: "Strength of medication; text field prompt"),
        ]
    }

    public internal(set) var scheduleType: Int = ScheduleType.NotCurrentlyTaken.rawValue
    public func scheduleTypeField() -> [NSObject : AnyObject] {
        return [
            FXFormFieldAction: "updateFields",
            FXFormFieldOptions: localizedScheduleTypes,
            FXFormFieldTitle: NSLocalizedString("Schedule Type", comment: "Schedule type; cell title"),
            FXFormFieldType: FXFormFieldTypeOption,
        ]
    }

    public internal(set) var times: NSArray = []
    public func timesField() -> [NSObject : AnyObject] {
        return [
            FXFormFieldOptions: localizedTimeOptions,
            FXFormFieldTitle: NSLocalizedString("Times", comment: "Medication alert times; section title"),
            FXFormFieldValueTransformer: valueTransformer,
        ]
    }

    public internal(set) var daysBetweenDoses: Int = 1
    public func daysBetweenDosesField() -> [NSObject : AnyObject] {
        return [
            FXFormFieldCell: FXFormStepperCell.self,
            FXFormFieldHeader: NSLocalizedString("Every X Days", comment: "Medication schedule type; name"),
            "stepper.maximumValue": 28,
            "stepper.minimumValue": 1,
            "stepper.wraps": true,
        ]
    }

    public internal(set) var startDate = NSDate()
    public func startDateField() -> [NSObject : AnyObject] {
        return [
            FXFormFieldTitle: NSLocalizedString("Start Date", comment: "'Every X days' schedule type; cell prompt"),
        ]
    }

    public internal(set) var weeklyDays: Int = 0
    public func weeklyDaysField() -> [NSObject : AnyObject] {
        return [
            FXFormFieldHeader: NSLocalizedString("Weekly", comment: "Medication schedule type; name"),
            FXFormFieldTitle: NSLocalizedString("Days Doses Are Taken", comment: "'Weekly'/'Monthly' schedule type; cell prompt"),
            FXFormFieldType: FXFormFieldTypeBitfield,
            FXFormFieldOptions: dateFormatter.standaloneWeekdaySymbols
        ]
    }

    public internal(set) var monthlyDays: Int = 0
    public func monthlyDaysField() -> [NSObject : AnyObject] {
        return [
            FXFormFieldHeader: NSLocalizedString("Monthly", comment: "Medication schedule type; name"),
            FXFormFieldTitle: NSLocalizedString("Days Doses Are Taken", comment: "'Weekly'/'Monthly' schedule type; cell prompt"),
            FXFormFieldType: FXFormFieldTypeBitfield,
            FXFormFieldOptions: localizedMonthlyDays,
        ]
    }

    public var localizedScheduleTypes: [String] {
        return [
            NSLocalizedString("Daily", comment: "Medication schedule type; name"),
            NSLocalizedString("Every X Days", comment: "Medication schedule type; name"),
            NSLocalizedString("Weekly", comment: "Medication schedule type; name"),
            NSLocalizedString("Monthly", comment: "Medication schedule type; name"),
            NSLocalizedString("Not Currently Taken", comment: "Medication schedule type; name"),
        ]
    }

    public var localizedMonthlyDays: [String] {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formattingContext = .Standalone
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .OrdinalStyle

        return (1...28).map { (i: Int) -> String in
            return numberFormatter.stringFromNumber(i) ?? undefined("Could not create ordinal string from number \(i)")
        }
    }

    public var localizedTimeOptions: [String] {
        return Array(stride(from: 0, to: 24 * 60 * 60, by: 30 * 60)).map { (timeInterval: NSTimeInterval) -> String in
            let date = NSDate(timeIntervalSinceReferenceDate: timeInterval)
            return self.valueTransformer.transformedValue(date) as! String
        }
    }

    public func fields() -> [AnyObject] {
        var fields: [AnyObject] = ["name", "strength", "scheduleType"]

        let scheduleType = ScheduleType(rawValue: self.scheduleType) ?? undefined("rawValue \(self.scheduleType) unsupported by ScheduleType")
        if scheduleType != .NotCurrentlyTaken {
            fields += ["times"]
        }

        switch scheduleType {
        case .EveryXDays:
            fields += ["daysBetweenDoses", "startDate"]
        case .Weekly:
            fields += ["weeklyDays"]
        case .Monthly:
            fields += ["monthlyDays"]
        case .Daily, .NotCurrentlyTaken:
            break
        }
        
        return fields
    }
}

public protocol MedicationDetailViewModelActions {
    func updateFields()
}
