import AddressBook

public struct SocialProfile: Equatable, MultiValueRepresentable, Printable {
    public struct Services {
        public static let Twitter = kABPersonSocialProfileServiceTwitter as String
        public static let SinaWeibo = kABPersonSocialProfileServiceSinaWeibo as String
        public static let GameCenter = kABPersonSocialProfileServiceGameCenter as String
        public static let Facebook = kABPersonSocialProfileServiceFacebook as String
        public static let Myspace = kABPersonSocialProfileServiceMyspace as String
        public static let LinkedIn = kABPersonSocialProfileServiceLinkedIn as String
        public static let Flickr = kABPersonSocialProfileServiceFlickr as String
    }

    public var URL: String
    public var service: String?
    public var username: String?
    public var userIdentifier: String?

    public init(URL: String, service: String?, username: String?, userIdentifier: String?) {
        self.URL = URL
        self.service = service
        self.username = username
        self.userIdentifier = userIdentifier
    }

    public static let multiValueType = PropertyKind.Dictionary

    public var multiValueRepresentation: CFTypeRef {
        var result = [NSObject : AnyObject]()
        result[kABPersonSocialProfileURLKey as String] = URL

        if let service = service {
            result[kABPersonSocialProfileServiceKey as String] = service
        }

        if let username = username {
            result[kABPersonSocialProfileUsernameKey as String] = username
        }

        if let userIdentifier = userIdentifier {
            result[kABPersonSocialProfileUserIdentifierKey as String] = userIdentifier
        }

        return result
    }

    public init?(multiValueRepresentation: CFTypeRef) {
        if let dictionary = multiValueRepresentation as? [NSObject : AnyObject],
            URL = dictionary[kABPersonSocialProfileURLKey as String] as? String {
                self.URL = URL
                self.service = dictionary[kABPersonSocialProfileServiceKey as String] as? String
                self.username = dictionary[kABPersonSocialProfileUsernameKey as String] as? String
                self.userIdentifier = dictionary[kABPersonSocialProfileUserIdentifierKey as String] as? String
        } else {
            return nil
        }
    }

    public var description: String {
        let transform: String -> String = { "\"\($0)\"" }
        let serviceOrNil = service.map(transform) ?? "nil"
        let usernameOrNil = username.map(transform) ?? "nil"
        let userIdentifierOrNil = userIdentifier.map(transform) ?? "nil"
        return "URL: \"\(URL)\", Service: \(serviceOrNil), Username: \(usernameOrNil), User Identifier: \(userIdentifierOrNil)"
    }
}

public func ==(lhs: SocialProfile, rhs: SocialProfile) -> Bool {
    return lhs.URL == rhs.URL && lhs.service == rhs.service && lhs.username == rhs.username && lhs.userIdentifier == rhs.userIdentifier
}
