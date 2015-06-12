import Foundation
import Monocle
import Pistachio

public struct Time {
    var hour: Int
    var minute: Int

    public init() {
        self.init(hour: 0, minute: 0)
    }

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}

// MARK: - CustomStringConvertible

extension Time: CustomStringConvertible {
    public var description: String {
        let hourString: String = {
            let prefix: String
            if hour < 10 {
                prefix = "0"
            } else {
                prefix = ""
            }

            return prefix + String(hour)
        }()

        let minuteString: String = {
            let prefix: String
            if minute < 10 {
                prefix = "0"
            } else {
                prefix = ""
            }

            return prefix + String(minute)
        }()

        return "\(hourString):\(minuteString)"
    }
}

// MARK: - Date Components

extension Time {
    public init?(dateComponents: NSDateComponents) {
        if dateComponents.hour == Int(NSDateComponentUndefined) || dateComponents.minute == Int(NSDateComponentUndefined) {
            return nil
        }

        self.hour = dateComponents.hour
        self.minute = dateComponents.minute
    }

    public var dateComponents: NSDateComponents {
        let dateComponents = NSDateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        return dateComponents
    }
}

// MARK: - Hashable

extension Time: Hashable {
    public var hashValue: Int {
        return hour.hashValue * 31 + minute.hashValue
    }
}

// MARK: - Equatable

extension Time: Equatable {}

public func ==(lhs: Time, rhs: Time) -> Bool {
    return lhs.hour == rhs.hour && lhs.minute == rhs.minute
}

// MARK: - Comparable

extension Time: Comparable {}

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
    public static let hour = Lens(
        get: { $0.hour },
        set: { (inout time: Time, hour) in time.hour = hour }
    )

    public static let minute = Lens(
        get: { $0.minute },
        set: { (inout time: Time, minute) in time.minute = minute }
    )
}
