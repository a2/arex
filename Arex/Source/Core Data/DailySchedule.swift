import CoreData
import Foundation

class DailySchedule: Schedule {
    enum Attributes: String {
        case hour = "hour"
        case minute = "minute"
        case repeatCount = "repeatCount"
        case repeatInterval = "repeatInterval"
    }
    
    // MARK: - Helpers

    override class var entityName: String {
        return "DailySchedule"
    }

    override class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life Cycle Methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext) {
        let entity = DailySchedule.entity(managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
    }

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
