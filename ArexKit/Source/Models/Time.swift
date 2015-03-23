import Foundation
import Pistachio

public struct Time: Comparable, Equatable, Hashable {
    var hour: Int
    var minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    public init(dateComponents: NSDateComponents) {
        precondition(dateComponents.hour != Int(NSDateComponentUndefined), "dateComponents.hour must not be undefined")
        self.hour = dateComponents.hour

        precondition(dateComponents.minute != Int(NSDateComponentUndefined), "dateComponents.minute must not be undefined")
        self.minute = dateComponents.minute
    }

    public var dateComponents: NSDateComponents {
        let dateComponents = NSDateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        return dateComponents
    }

    public var hashValue: Int {
        return hour.hashValue ^ minute.hashValue
    }
}

public func ==(lhs: Time, rhs: Time) -> Bool {
    return lhs.hour == rhs.hour && lhs.minute == rhs.minute
}

public func <(lhs: Time, rhs: Time) -> Bool {
    if lhs.hour < rhs.hour {
        return true
    } else if lhs.hour == rhs.hour {
        return lhs.minute < rhs.minute
    } else {
        return false
    }
}

public struct TimeLenses {
    public static let hour = Lens(get: { $0.hour }, set: { (inout time: Time, hour) in time.hour = hour })
    public static let minute = Lens(get: { $0.minute }, set: { (inout time: Time, minute) in time.minute = minute })
}
