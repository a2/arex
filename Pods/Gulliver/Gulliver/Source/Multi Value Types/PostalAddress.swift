import AddressBook
import AddressBookUI

public struct PostalAddress: DebugPrintable, Equatable, MultiValueRepresentable, Printable {
    public var street: String?
    public var city: String?
    public var state: String?
    public var postalCode: String?
    public var country: String?
    public var ISOCountryCode: String?

    public init(street: String?, city: String?, state: String?, postalCode: String?, country: String?, ISOCountryCode: String?) {
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.ISOCountryCode = ISOCountryCode
    }

    public static let multiValueType = PropertyKind.Dictionary

    public var multiValueRepresentation: CFTypeRef {
        var result = [NSObject : AnyObject]()

        if let street = street {
            result[kABPersonAddressStreetKey as String] = street
        }

        if let city = city {
            result[kABPersonAddressCityKey as String] = city
        }

        if let state = state {
            result[kABPersonAddressStateKey as String] = state
        }

        if let postalCode = postalCode {
            result[kABPersonAddressZIPKey as String] = postalCode
        }

        if let country = country {
            result[kABPersonAddressCountryKey as String] = country
        }

        if let ISOCountryCode = ISOCountryCode {
            result[kABPersonAddressCountryCodeKey as String] = ISOCountryCode
        }

        return result
    }

    public init?(multiValueRepresentation: CFTypeRef) {
        if let dictionary = multiValueRepresentation as? [NSObject : AnyObject] {
            self.street = dictionary[kABPersonAddressStreetKey as String] as? String
            self.city = dictionary[kABPersonAddressCityKey as String] as? String
            self.state = dictionary[kABPersonAddressStateKey as String] as? String
            self.postalCode = dictionary[kABPersonAddressZIPKey as String] as? String
            self.country = dictionary[kABPersonAddressCountryKey] as? String
            self.ISOCountryCode = dictionary[kABPersonAddressCountryCodeKey] as? String
        } else {
            return nil
        }
    }

    public var description: String {
        let address = multiValueRepresentation as! [NSObject : AnyObject]
        return ABCreateStringWithAddressDictionary(address, true)
    }

    public var debugDescription: String {
        return toDebugString(multiValueRepresentation)
    }
}

public func ==(lhs: PostalAddress, rhs: PostalAddress) -> Bool {
    return lhs.street == rhs.street && lhs.city == rhs.city && lhs.state == rhs.state && lhs.postalCode == rhs.postalCode && lhs.country == rhs.country && lhs.ISOCountryCode == rhs.ISOCountryCode
}
