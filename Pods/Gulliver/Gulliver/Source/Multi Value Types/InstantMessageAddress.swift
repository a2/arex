import AddressBook

public struct InstantMessageAddress: Equatable, MultiValueRepresentable, Printable {
    public struct Services {
        public static let Yahoo = kABPersonInstantMessageServiceYahoo as String
        public static let Jabber = kABPersonInstantMessageServiceJabber as String
        public static let MSN = kABPersonInstantMessageServiceMSN as String
        public static let ICQ = kABPersonInstantMessageServiceICQ as String
        public static let AIM = kABPersonInstantMessageServiceAIM as String
        public static let QQ = kABPersonInstantMessageServiceQQ as String
        public static let GoogleTalk = kABPersonInstantMessageServiceGoogleTalk as String
        public static let Skype = kABPersonInstantMessageServiceSkype as String
        public static let Facebook = kABPersonInstantMessageServiceFacebook as String
        public static let GaduGadu = kABPersonInstantMessageServiceGaduGadu as String
    }

    public var service: String?
    public var username: String?

    public init(service: String?, username: String?) {
        self.service = service
        self.username = username
    }

    public static let multiValueType = PropertyKind.Dictionary

    public var multiValueRepresentation: CFTypeRef {
        var result = [NSObject : AnyObject]()

        if let service = service {
            result[kABPersonInstantMessageServiceKey as String] = service
        }

        if let username = username {
            result[kABPersonInstantMessageUsernameKey as String] = username
        }

        return result
    }

    public init?(multiValueRepresentation: CFTypeRef) {
        if let dictionary = multiValueRepresentation as? [NSObject : AnyObject],
            username = dictionary[kABPersonInstantMessageUsernameKey as String] as? String?,
            service = dictionary[kABPersonInstantMessageServiceKey as String] as? String? {
                self.init(service: service, username: username)
        } else {
            return nil
        }
    }

    public var description: String {
        let transform: String -> String = { "\"\($0)\"" }
        let serviceOrNil = service.map(transform) ?? "nil"
        let usernameOrNil = username.map(transform) ?? "nil"
        return "Service: \(serviceOrNil), Username: \(usernameOrNil)"
    }
}

public func ==(lhs: InstantMessageAddress, rhs: InstantMessageAddress) -> Bool {
    return lhs.service == rhs.service && lhs.username == rhs.username
}
