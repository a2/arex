import AddressBook

public enum PersonKind: Printable, RawRepresentable {
    case Person
    case Organization

    public var rawValue: CFNumberRef {
        switch self {
        case .Person:
            return kABPersonKindPerson
        case .Organization:
            return kABPersonKindOrganization
        }
    }

    public init?(rawValue: CFNumberRef) {
        if CFNumberCompare(rawValue, kABPersonKindPerson, nil) == .CompareEqualTo {
            self = .Person
        } else if CFNumberCompare(rawValue, kABPersonKindOrganization, nil) == .CompareEqualTo {
            self = .Organization
        } else {
            return nil
        }
    }

    public var description: String {
        switch self {
        case .Person:
            return "Person"
        case .Organization:
            return "Organization"
        }
    }
}
