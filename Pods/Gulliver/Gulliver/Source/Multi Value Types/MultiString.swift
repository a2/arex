import AddressBook

public struct MultiString: Equatable, MultiValueRepresentable, Printable, StringLiteralConvertible {
    public var value: String

    public init(_ value: String) {
        self.value = value
    }

    public static let multiValueType = PropertyKind.String

    public var multiValueRepresentation: CFTypeRef {
        return value
    }

    public init?(multiValueRepresentation: CFTypeRef) {
        if let value = multiValueRepresentation as? String {
            self.value = value
        } else {
            return nil
        }
    }

    public var description: String {
        return value
    }

    public init(stringLiteral: String) {
        self.value = stringLiteral
    }

    public init(extendedGraphemeClusterLiteral: String) {
        self.value = extendedGraphemeClusterLiteral
    }

    public init(unicodeScalarLiteral: String) {
        self.value = unicodeScalarLiteral
    }
}

public func ==(lhs: MultiString, rhs: MultiString) -> Bool {
    return lhs.value == rhs.value
}

public struct PhoneNumber {
    public struct Labels {
        public static let Mobile = kABPersonPhoneMobileLabel as String
        public static let IPhone = kABPersonPhoneIPhoneLabel as String
        public static let Main = kABPersonPhoneMainLabel as String
        public static let HomeFAX = kABPersonPhoneHomeFAXLabel as String
        public static let WorkFAX = kABPersonPhoneWorkFAXLabel as String
        public static let OtherFAX = kABPersonPhoneOtherFAXLabel as String
        public static let Pager = kABPersonPhonePagerLabel as String
    }
}

public struct RelatedName {
    public struct Labels {
        public static let Father = kABPersonFatherLabel as String
        public static let Mother = kABPersonMotherLabel as String
        public static let Parent = kABPersonParentLabel as String
        public static let Brother = kABPersonBrotherLabel as String
        public static let Sister = kABPersonSisterLabel as String
        public static let Child = kABPersonChildLabel as String
        public static let Friend = kABPersonFriendLabel as String
        public static let Spouse = kABPersonSpouseLabel as String
        public static let Partner = kABPersonPartnerLabel as String
        public static let Assistant = kABPersonAssistantLabel as String
        public static let Manager = kABPersonManagerLabel as String
    }
}

public struct URL {
    public struct Labels {
        public static let HomePage = kABPersonHomePageLabel as String
    }
}
