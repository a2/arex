import AddressBook

public enum SourceKind: Printable, RawRepresentable {
    case Local
    case Exchange
    case ExchangeGAL
    case MobileMe
    case LDAP
    case CardDAV
    case CardDAVSearch

    public var isSearchable: Bool {
        return rawValue & kABSourceTypeSearchableMask != 0
    }

    public var rawValue: ABSourceType {
        switch self {
        case .Local:
            return numericCast(kABSourceTypeLocal)
        case .Exchange:
            return numericCast(kABSourceTypeExchange)
        case .ExchangeGAL:
            return numericCast(kABSourceTypeExchangeGAL)
        case .MobileMe:
            return numericCast(kABSourceTypeMobileMe)
        case .LDAP:
            return numericCast(kABSourceTypeLDAP)
        case .CardDAV:
            return numericCast(kABSourceTypeCardDAV)
        case .CardDAVSearch:
            return numericCast(kABSourceTypeCardDAVSearch)
        }
    }

    public init?(rawValue: ABSourceType) {
        let intValue: Int = numericCast(rawValue)
        switch intValue {
        case kABSourceTypeLocal:
            self = .Local
        case kABSourceTypeExchange:
            self = .Exchange
        case kABSourceTypeExchangeGAL:
            self = .ExchangeGAL
        case kABSourceTypeMobileMe:
            self = .MobileMe
        case kABSourceTypeLDAP:
            self = .LDAP
        case kABSourceTypeCardDAV:
            self = .CardDAV
        case kABSourceTypeCardDAVSearch:
            self = .CardDAVSearch
        default:
            return nil
        }
    }

    public var description: String {
        switch self {
        case .Local:
            return "Local"
        case .Exchange:
            return "Exchange"
        case .ExchangeGAL:
            return "ExchangeGAL"
        case .MobileMe:
            return "MobileMe"
        case .LDAP:
            return "LDAP"
        case .CardDAV:
            return "CardDAV"
        case .CardDAVSearch:
            return "CardDAVSearch"
        }
    }
}
