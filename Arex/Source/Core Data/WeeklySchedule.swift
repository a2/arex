import CoreData
import Foundation

class WeeklySchedule: Schedule {
    enum Attributes: String {
        case daysOfWeek = "daysOfWeek"
        case hour = "hour"
        case minute = "minute"
    }

    // MARK: - Helpers

    override class var entityName: String {
        return "WeeklySchedule"
    }

    override class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life Cycle Methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext) {
        let entity = WeeklySchedule.entity(managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
    }

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
