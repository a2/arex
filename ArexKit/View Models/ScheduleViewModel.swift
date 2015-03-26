extension MedicationDetailViewModel {
    public class ScheduleViewModel {
        private let schedule: Schedule
        private let dateFormatterClosure: Void -> NSDateFormatter
        private let dateComponentsFormatterClosure: Void -> NSDateComponentsFormatter
        private let timeFormatterClosure: Void -> NSDateFormatter

        public init(schedule: Schedule, @autoclosure(escaping) dateFormatter: Void -> NSDateFormatter, @autoclosure(escaping) timeFormatter: Void -> NSDateFormatter, @autoclosure(escaping) dateComponentsFormatter: Void -> NSDateComponentsFormatter) {
            self.dateFormatterClosure = dateFormatter
            self.dateComponentsFormatterClosure = dateComponentsFormatter
            self.schedule = schedule
            self.timeFormatterClosure = timeFormatter
        }

        public var localizedDescription: String {
            switch schedule {
            case let .Once(fireDate: fireDate, timeZone: timeZone):
                let dateFormatter = dateFormatterClosure()
                
                let previousTimeZone = dateFormatter.timeZone
                let format = NSLocalizedString("On %@", comment: "Medication detail; schedule; {date} is a localized date string")

                // TODO: #??: This is a hack.
                dateFormatter.timeZone = timeZone
                let localizedDate = dateFormatter.stringFromDate(fireDate)
                dateFormatter.timeZone = previousTimeZone

                return String(format: format, locale: dateFormatter.locale, arguments: [localizedDate])
            case let .Repeating(repeat: repeat, time: time):
                // TODO: Finish this implementation
                return undefined("Unimplemented")
            }
        }
    }
}
