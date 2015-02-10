import CoreData

class Schedule: NSManagedObject {
    enum Attributes: String {
        case on = "on"
    }

    enum Relationships: String {
        case medication = "medication"
    }

    // MARK: - Helpers

    class var entityName: String {
        return "Schedule"
    }

    class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life Cycle Methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext) {
        let entity = Schedule.entity(managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Attributes

    @NSManaged var on: NSNumber?
    var onValue: Bool? {
        get {
            return on?.boolValue
        }
        set {
            on = newValue.map { NSNumber(bool: $0) }
        }
    }

    // MARK: - Relationships

    @NSManaged var medication: Medication?
}
