import Foundation
import Pistachio

struct Time: Comparable, Equatable, Hashable {
    var hour: Int
    var minute: Int

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    init(dateComponents: NSDateComponents) {
        assert(dateComponents.hour != Int(NSDateComponentUndefined), "dateComponents.hour must not be undefined")
        assert(dateComponents.minute != Int(NSDateComponentUndefined), "dateComponents.minute must not be undefined")
        self.hour = dateComponents.hour
        self.minute = dateComponents.minute
    }

    var dateComponents: NSDateComponents {
        let dateComponents = NSDateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        return dateComponents
    }

    var hashValue: Int {
        return hour.hashValue ^ minute.hashValue
    }
}

func ==(lhs: Time, rhs: Time) -> Bool {
    return lhs.hour == rhs.hour && lhs.minute == rhs.minute
}

func <(lhs: Time, rhs: Time) -> Bool {
    if lhs.hour < rhs.hour {
        return true
    } else if lhs.hour == rhs.hour {
        return lhs.minute < rhs.minute
    } else {
        return false
    }
}

struct TimeLenses {
    static let hour = Lens(get: { $0.hour }, set: { (inout time: Time, hour) in time.hour = hour })
    static let minute = Lens(get: { $0.minute }, set: { (inout time: Time, minute) in time.minute = minute })
}
