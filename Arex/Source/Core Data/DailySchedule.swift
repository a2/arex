import CoreData
import Foundation

class DailySchedule: Schedule {
    // MARK: - Attributes
    
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

    @NSManaged var repeatCount: NSNumber?
    var repeatCountValue: Int16? {
        get {
            return repeatCount?.shortValue
        }
        set {
            repeatCount = newValue.map { NSNumber(short: $0) }
        }
    }

    @NSManaged var repeatInterval: NSNumber?
    var repeatIntervalValue: Int16? {
        get {
            return repeatInterval?.shortValue
        }
        set {
            repeatInterval = newValue.map { NSNumber(short: $0) }
        }
    }
}
