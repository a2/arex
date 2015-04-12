import AddressBook

public enum RecordKind: Printable, RawRepresentable {
    case Person
    case Group
    case Source

    public var rawValue: ABRecordType {
        switch self {
        case .Person:
            return numericCast(kABPersonType)
        case .Group:
            return numericCast(kABGroupType)
        case .Source:
            return numericCast(kABSourceType)
        }
    }

    public init?(rawValue: ABRecordType) {
        let intValue: Int = numericCast(rawValue)
        switch intValue {
        case kABPersonType:
            self = .Person
        case kABGroupType:
            self = .Group
        case kABSourceType:
            self = .Source
        default:
            return nil
        }
    }

    public var description: String {
        switch self {
        case .Person:
            return "Person"
        case .Group:
            return "Group"
        case .Source:
            return "Source"
        }
    }
}
