import CoreData
import Foundation

class MonthlySchedule: Schedule {
    // MARK: - Attributes

    @NSManaged var day: NSNumber?
    var dayValue: Int16? {
        get {
            return day?.shortValue
        }
        set {
            day = newValue.map { NSNumber(short: $0) }
        }
    }

    @NSManaged var hour: NSNumber?
    var hourValue: Int16? {
        get {
            return hour?.shortValue
        }
        set {
            hour = newValue.map { NSNumber(short: $0) }
        }
    }

    @NSManaged var minute: NSNumber?
    var minuteValue: Int16? {
        get {
            return minute?.shortValue
        }
        set {
            minute = newValue.map { NSNumber(short: $0) }
        }
    }

    @NSManaged var onDayOfWeek: NSNumber?
    var onDayOfWeekValue: Bool? {
        get {
            return onDayOfWeek?.boolValue
        }
        set {
            onDayOfWeek = newValue.map { NSNumber(bool: $0) }
        }
    }

    @NSManaged var week: NSNumber?
    var weekValue: Int16? {
        get {
            return week?.shortValue
        }
        set {
            week = newValue.map { NSNumber(short: $0) }
        }
    }
}
