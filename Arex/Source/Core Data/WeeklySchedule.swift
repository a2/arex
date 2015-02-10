import CoreData
import Foundation

class WeeklySchedule: Schedule {
    // MARK: - Attributes

    @NSManaged var daysOfWeek: NSNumber?
    var daysOfWeekValue: Int16? {
        get {
            return daysOfWeek?.shortValue
        }
        set {
            daysOfWeek = newValue.map { NSNumber(short: $0) }
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
}
