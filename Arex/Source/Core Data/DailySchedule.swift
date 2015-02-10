import CoreData

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
    @NSManaged var minute: NSNumber?
    @NSManaged var repeatCount: NSNumber?
    @NSManaged var repeatInterval: NSNumber?
}
