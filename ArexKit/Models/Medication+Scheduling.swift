import Pistachio
import Monocle

private func dayCompare(calendar: NSCalendar) -> (NSDate, NSDate) -> NSComparisonResult {
    return { a, b in
        return calendar.compareDate(a, toDate: b, toUnitGranularity: .Day)
    }
}

private func addDay(calendar: NSCalendar, date: NSDate) -> NSDate {
    var date = date
    date = calendar.dateByAddingUnit(.Day, value: 1, toDate: date, options: .MatchNextTime)!
    date = calendar.startOfDayForDate(date)
    return date
}

extension Medication {
    private func addTimesToDate(calendar: NSCalendar, date: NSDate) -> [NSDate] {
        let times = get(MedicationLenses.times, self)
        return times.flatMap { time -> NSDate? in
            let hour = get(TimeLenses.hour, time)
            let minute = get(TimeLenses.minute, time)
            return calendar.dateBySettingHour(hour, minute: minute, second: 0, ofDate: date, options: .MatchNextTimePreservingSmallerUnits)
        }
    }

    private func dailyDates(calendar: NSCalendar, from: NSDate, to: NSDate) -> [NSDate] {
        return everyXDaysDates(interval: 1, startDate: from)(calendar: calendar, from: from, to: to)
    }

    private func everyXDaysDates(interval interval: Int, startDate: NSDate) -> (calendar: NSCalendar, from: NSDate, to: NSDate) -> [NSDate] {
        return { calendar, from, to in
            let compare = dayCompare(calendar)
            if compare(startDate, to) == .OrderedDescending {
                return []
            }

            var date = startDate
            var dates = [NSDate]()
            var daysSinceFrom = 0
            while compare(date, to) != .OrderedDescending {
                if daysSinceFrom % interval == 0 && compare(date, from) != .OrderedAscending {
                    dates += self.addTimesToDate(calendar, date: date)
                }

                date = addDay(calendar, date: date)
                daysSinceFrom += 1
            }

            return dates
        }
    }
    
    private func weeklyDates(days days: Int) -> (calendar: NSCalendar, from: NSDate, to: NSDate) -> [NSDate] {
        return { calendar, from, to in
            let compare = dayCompare(calendar)
            var date = from
            var dates = [NSDate]()
            while compare(date, to) != .OrderedDescending {
                let weekday = calendar.component(.Weekday, fromDate: date)
                if (days & (1 << (weekday - 1))) != 0 {
                    dates += self.addTimesToDate(calendar, date: date)
                }

                date = addDay(calendar, date: date)
            }

            return dates
        }
    }
    
    private func monthlyDates(days days: Int) -> (calendar: NSCalendar, from: NSDate, to: NSDate) -> [NSDate] {
        return { calendar, from, to in
            let compare = dayCompare(calendar)
            var date = from
            var dates = [NSDate]()
            while compare(date, to) != .OrderedDescending {
                let monthDay = calendar.component(.Day, fromDate: date)
                if (days & (1 << (monthDay - 1))) != 0 {
                    dates += self.addTimesToDate(calendar, date: date)
                }

                date = addDay(calendar, date: date)
            }

            return dates
        }
    }
    
    public func dates(inCalendar calendar: NSCalendar, from: NSDate, to: NSDate) -> [NSDate] {
        let schedule = get(MedicationLenses.schedule, self)
        let generator: (calendar: NSCalendar, from: NSDate, to: NSDate) -> [NSDate]

        switch schedule {
        case .Daily:
            generator = dailyDates
        case let .EveryXDays(interval: interval, startDate: startDate):
            generator = everyXDaysDates(interval: interval, startDate: startDate)
        case let .Weekly(days: days):
            generator = weeklyDates(days: days)
        case let .Monthly(days: days):
            generator = monthlyDates(days: days)
        case .NotCurrentlyTaken:
            generator = { _ in [] }
        }

        return generator(calendar: calendar, from: from, to: to).sort()
    }
}
