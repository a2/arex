import AddressBook

public enum PropertyKind: Printable, RawRepresentable {
    case Invalid
    case String
    case Integer
    case Real
    case DateTime
    case Dictionary
    case MultiString
    case MultiInteger
    case MultiReal
    case MultiDateTime
    case MultiDictionary

    public var isValid: Bool {
        return self != .Invalid
    }

    public var isMulti: Bool {
        switch self {
        case .MultiString, .MultiInteger, .MultiReal, .MultiDateTime, .MultiDictionary:
            return true
        default:
            return false
        }
    }

    public var rawValue: ABPropertyType {
        switch self {
        case .Invalid:
            return numericCast(kABInvalidPropertyType)
        case .String:
            return numericCast(kABStringPropertyType)
        case .Integer:
            return numericCast(kABIntegerPropertyType)
        case .Real:
            return numericCast(kABRealPropertyType)
        case .DateTime:
            return numericCast(kABDateTimePropertyType)
        case .Dictionary:
            return numericCast(kABDictionaryPropertyType)
        case .MultiString:
            return numericCast(kABMultiStringPropertyType)
        case .MultiInteger:
            return numericCast(kABMultiIntegerPropertyType)
        case .MultiReal:
            return numericCast(kABMultiRealPropertyType)
        case .MultiDateTime:
            return numericCast(kABMultiDateTimePropertyType)
        case .MultiDictionary:
            return numericCast(kABMultiDictionaryPropertyType)
        }
    }

    public init?(rawValue: ABPropertyType) {
        let intValue: Int = numericCast(rawValue)
        switch intValue {
        case kABInvalidPropertyType:
            self = .Invalid
        case kABStringPropertyType:
            self = .String
        case kABIntegerPropertyType:
            self = .Integer
        case kABRealPropertyType:
            self = .Real
        case kABDateTimePropertyType:
            self = .DateTime
        case kABDictionaryPropertyType:
            self = .Dictionary
        case kABMultiStringPropertyType:
            self = .MultiString
        case kABMultiIntegerPropertyType:
            self = .MultiInteger
        case kABMultiRealPropertyType:
            self = .MultiReal
        case kABMultiDateTimePropertyType:
            self = .MultiDateTime
        case kABMultiDictionaryPropertyType:
            self = .MultiDictionary
        default:
            return nil
        }
    }

    public var description: Swift.String {
        switch self {
        case .Invalid:
            return "Invalid"
        case .String:
            return "String"
        case .Integer:
            return "Integer"
        case .Real:
            return "Real"
        case .DateTime:
            return "DateTime"
        case .Dictionary:
            return "Dictionary"
        case .MultiString:
            return "MultiString"
        case .MultiInteger:
            return "MultiInteger"
        case .MultiReal:
            return "MultiReal"
        case .MultiDateTime:
            return "MultiDateTime"
        case .MultiDictionary:
            return "MultiDictionary"
        }
    }
}
