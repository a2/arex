import CoreData
import Foundation

class MonthlySchedule: Schedule {
    enum Attributes: String {
        case dayOfMonth = "dayOfMonth"
        case dayOfWeek = "dayOfWeek"
        case hour = "hour"
        case minute = "minute"
        case onDayOfWeek = "onDayOfWeek"
        case weekOfMonth = "weekOfMonth"
    }

    // MARK: - Helpers

    override class var entityName: String {
        return "MonthlySchedule"
    }

    override class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life Cycle Methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext) {
        let entity = MonthlySchedule.entity(managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
    }

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
