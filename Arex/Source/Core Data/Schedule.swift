import CoreData
import Foundation

class Schedule: NSManagedObject {
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
