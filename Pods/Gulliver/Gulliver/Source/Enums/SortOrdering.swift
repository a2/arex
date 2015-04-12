import AddressBook

public enum SortOrdering: Printable, RawRepresentable {
    case ByFirstName
    case ByLastName

    public var rawValue: ABPersonSortOrdering {
        switch self {
        case .ByFirstName:
            return numericCast(kABPersonSortByFirstName)
        case .ByLastName:
            return numericCast(kABPersonSortByLastName)
        }
    }

    public init?(rawValue: ABPersonSortOrdering) {
        let intValue: Int = numericCast(rawValue)
        switch intValue {
        case kABPersonSortByFirstName:
            self = .ByFirstName
        case kABPersonSortByLastName:
            self = .ByLastName
        default:
            return nil
        }
    }

    public var description: String {
        switch self {
        case .ByFirstName:
            return "ByFirstName"
        case .ByLastName:
            return "ByLastName"
        }
    }
}
