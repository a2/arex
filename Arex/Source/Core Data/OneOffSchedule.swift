import CoreData
import Foundation

class OneOffSchedule: Schedule {
    // MARK: - Attributes

    @NSManaged var fireDate: NSDate?
    @NSManaged var timeZone: NSTimeZone?
}
