import AddressBook
import CoreData
import UIKit

class Medication: NSManagedObject {
    enum Attributes: String {
        case doctorRecordID = "doctorRecordID"
        case dosesLeft = "dosesLeft"
        case lastFilledDate = "lastFilledDate"
        case name = "name"
        case note = "note"
        case pharmacyRecordID = "pharmacyRecordID"
        case pictureData = "pictureData"
        case strength = "strength"
    }

    enum Relationships: String {
        case schedules = "schedules"
    }
    
    // MARK: - Helpers

    class var entityName: String {
        return "Medication"
    }

    class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life Cycle Methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext) {
        let entity = Medication.entity(managedObjectContext)
        self.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Attributes

    @NSManaged var doctorRecordID: NSNumber?
    var doctorRecordIDValue: ABRecordID? {
        get {
            return doctorRecordID?.intValue
        }
        set {
            doctorRecordID = newValue.map { NSNumber(int: $0) }
        }
    }

    @NSManaged var dosesLeft: NSNumber?
    var dosesLeftValue: Int16? {
        get {
            return dosesLeft?.shortValue
        }
        set {
            dosesLeft = newValue.map { NSNumber(short: $0) }
        }
    }

    @NSManaged var lastFilledDate: NSDate?

    @NSManaged var name: String?

    @NSManaged var note: String?

    @NSManaged var pharmacyRecordID: NSNumber?
    var pharmacyRecordIDValue: ABRecordID? {
        get {
            return pharmacyRecordID?.intValue
        }
        set {
            pharmacyRecordID = newValue.map { NSNumber(int: $0) }
        }
    }

    @NSManaged var pictureData: NSData?
    var picture: UIImage? {
        get {
            return pictureData.map { UIImage(data: $0) } ?? nil
        }
        set {
            pictureData = newValue.map { UIImageJPEGRepresentation($0, 0.7) }
        }
    }

    @NSManaged var strength: String?

    // MARK: - Relationships

    @NSManaged var schedules: NSOrderedSet
}
