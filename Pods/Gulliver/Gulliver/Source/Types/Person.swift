import AddressBook
import Lustre

public let WorkLabel = kABWorkLabel as String
public let HomeLabel = kABHomeLabel as String
public let OtherLabel = kABOtherLabel as String

public final class Person: Record, PersonType {
    public typealias GroupState = ABRecordRef
    public typealias SourceState = ABRecordRef

    public required init(state: ABRecordRef) {
        precondition(RecordKind(rawValue: ABRecordGetRecordType(state)) == .Person, "ABRecordRef \(state) is not a person")
        super.init(state: state)
    }

    public convenience init() {
        let state: ABRecordRef = ABPersonCreate().takeRetainedValue()
        self.init(state: state)
    }

    public var hasImageData: Bool {
        return ABPersonHasImageData(state)
    }

    public func imageData() -> NSData? {
        if let data = ABPersonCopyImageData(state) {
            return data.takeUnretainedValue() as NSData
        } else {
            return nil
        }
    }

    public func imageData(format: ImageFormat) -> NSData? {
        if let data = ABPersonCopyImageDataWithFormat(state, format.rawValue) {
            return data.takeRetainedValue() as NSData
        } else {
            return nil
        }
    }

    public func setImageData(imageData: NSData?) -> VoidResult {
        var error: Unmanaged<CFErrorRef>? = nil
        if let imageData = imageData {
            if ABPersonSetImageData(state, imageData, &error) {
                return success()
            }
        } else {
            if ABPersonRemoveImageData(state, &error) {
                return success()
            }
        }

        if let error = error {
            return failure(error.takeUnretainedValue())
        } else {
            return failure("An unexpected error occurred.")
        }
    }

    public static var sortOrdering: SortOrdering {
        return SortOrdering(rawValue: ABPersonGetSortOrdering())!
    }

    public func source<S: _SourceType where S.State == SourceState>() -> S {
        let sourceState: ABRecordRef = ABPersonCopySource(state).takeRetainedValue()
        return S(state: sourceState)
    }

    public func linkedPeople<P: _PersonType where P.State == Person.State>() -> [P] {
        let people = ABPersonCopyArrayOfAllLinkedPeople(state)
        let array = people.takeRetainedValue() as [ABRecordRef]
        return array.map({ P(state: $0) })
    }

    public var compositeNameFormat: CompositeNameFormat {
        return CompositeNameFormat(rawValue: ABPersonGetCompositeNameFormatForRecord(state))!
    }

    public var compositeNameDelimiter: String {
        return ABPersonCopyCompositeNameDelimiterForRecord(state).takeRetainedValue() as String
    }

    public class func vCardRepresentation<P: _PersonType where P.State == Person.State>(people: [P]) -> NSData {
        let personStates = people.map({ $0.state })
        return ABPersonCreateVCardRepresentationWithPeople(personStates).takeRetainedValue() as NSData
    }

    public class func compare<P1: _PersonType, P2: _PersonType where P1.State == Person.State, P2.State == Person.State>(person1: P1, person2: P2, ordering: SortOrdering) -> NSComparisonResult {
        switch ABPersonComparePeopleByName(person1.state, person2.state, ordering.rawValue) {
        case .CompareEqualTo:
            return .OrderedSame
        case .CompareGreaterThan:
            return .OrderedDescending
        case .CompareLessThan:
            return .OrderedAscending
        }
    }

    public class func people<P: _PersonType, S: _SourceType where P.State == Person.State, S.State == SourceState>(vCardRepresentation: NSData, source: S?) -> [P]? {
        if let unmanagedPeople = ABPersonCreatePeopleInSourceWithVCardRepresentation(source?.state, vCardRepresentation as CFDataRef) {
            let people = unmanagedPeople.takeRetainedValue() as [ABRecordRef]
            return people.map({ P(state: $0) })
        } else {
            return nil
        }
    }
}

public struct PersonProperty {
    public static let FirstName = MutableProperty<String>(propertyID: kABPersonFirstNameProperty)
    public static let LastName = MutableProperty<String>(propertyID: kABPersonLastNameProperty)
    public static let MiddleName = MutableProperty<String>(propertyID: kABPersonMiddleNameProperty)
    public static let Prefix = MutableProperty<String>(propertyID: kABPersonPrefixProperty)
    public static let Suffix = MutableProperty<String>(propertyID: kABPersonSuffixProperty)
    public static let Nickname = MutableProperty<String>(propertyID: kABPersonNicknameProperty)
    public static let FirstNamePhonetic = MutableProperty<String>(propertyID: kABPersonFirstNamePhoneticProperty)
    public static let LatNamePhonetic = MutableProperty<String>(propertyID: kABPersonLastNamePhoneticProperty)
    public static let MiddleNamePhonetic = MutableProperty<String>(propertyID: kABPersonMiddleNamePhoneticProperty)
    public static let Organization = MutableProperty<String>(propertyID: kABPersonOrganizationProperty)
    public static let JobTitle = MutableProperty<String>(propertyID: kABPersonJobTitleProperty)
    public static let Department = MutableProperty<String>(propertyID: kABPersonDepartmentProperty)
    public static let Emails = MutableProperty<[LabeledValue<MultiString>]>(propertyID: kABPersonEmailProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let Birthday = MutableProperty<NSDate>(propertyID: kABPersonBirthdayProperty)
    public static let Note = MutableProperty<String>(propertyID: kABPersonNoteProperty)
    public static let CreationDate = Property<NSDate>(propertyID: kABPersonCreationDateProperty)
    public static let ModificationDate = Property<NSDate>(propertyID: kABPersonModificationDateProperty)
    public static let Addresses = MutableProperty<[LabeledValue<PostalAddress>]>(propertyID: kABPersonAddressProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let Dates = MutableProperty<[LabeledValue<MultiDate>]>(propertyID: kABPersonDateProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let Kind = MutableProperty<PersonKind>(propertyID: kABPersonKindProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let Phones = MutableProperty<[LabeledValue<MultiString>]>(propertyID: kABPersonPhoneProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let InstantMessages = MutableProperty<[LabeledValue<InstantMessageAddress>]>(propertyID: kABPersonInstantMessageProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let URLs = MutableProperty<[LabeledValue<MultiString>]>(propertyID: kABPersonURLProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let RelatedNames = MutableProperty<[LabeledValue<MultiString>]>(propertyID: kABPersonRelatedNamesProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let SocialProfiles = MutableProperty<[LabeledValue<SocialProfile>]>(propertyID: kABPersonSocialProfileProperty, readTransform: readTransform, writeTransform: writeTransform)
    public static let AlternateBirthday = MutableProperty<Gulliver.AlternateBirthday>(propertyID: kABPersonAlternateBirthdayProperty, readTransform: readTransform, writeTransform: writeTransform)
}
