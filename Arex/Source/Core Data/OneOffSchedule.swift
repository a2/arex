import CoreData
import Foundation

class OneOffSchedule: Schedule {
    enum Attributes: String {
        case fireDate = "fireDate"
        case timeZone = "timeZone"
    }

    // MARK: - Helpers

    override class var entityName: String {
        return "OneOffSchedule"
    }

    override class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life Cycle Methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext) {
        let entity = OneOffSchedule.entity(managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
    }
    
    // MARK: - Attributes

    @NSManaged var fireDate: NSDate?
    @NSManaged var timeZone: NSTimeZone?
}
