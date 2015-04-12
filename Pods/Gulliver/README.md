# Gulliver

A Swift wrapper for the iOS AddressBook framework.

## What's in the box?

### Enums

* **AuthorizationStatus:** ABAuthorizationStatus
* **CompositeNameFormat:** ABPersonCompositeNameFormat
* **ImageFormat:** ABPersonImageFormat
* **PersonKind:** "ABPersonKind" (CFNumberRef)
* **PropertyKind:** ABPropertyType
* **SortOrdering:** ABPersonSortOrdering
* **SourceKind:** ABSourceType
* **RecordKind:** ABRecordType

The enums that come with AddressBook.framework are gross. They aren't declared correctly. Instead of using `CF_ENUM` and `CF_OPTIONS`, AddressBook.framework prefers to create anonymous enums followed by a typedef-ed type.

What this means is that you have `ABRecordType` aliased to `UInt32` and three orphan declarations (`kABPersonType`, `kABGroupType`, `kABSourceType`) imported to Swift as `Int`s.

As well, the `kABPersonKindProperty` property does not contain an `ABPersonKind` wrapped in a `CFNumberRef`. It contains either `kABPersonKindPerson` or `kABPersonKindOrganization` (both static `CFNumberRef`s).

### Helpers

> Pay no attention to the man behind the curtain.

Implementation details live here, such as:

* An extension for Zachary Waldowski's brilliant [Lustre](https://github.com/zwaldowski/Lustre) framework that allows easier creation of `ResultType` values with `CFErrorRef` errors.
* A `ABExternalChangeCallback` that can be used for block-based external change registration (and dereigstration) for `ABAddressBookRef`s. The `ABAddressBookRegisterExternalChangeCallback` function requires a function pointer to call when an external change happens. Swift imports this required type as a useless `CFunctionPointer`; for this reason, a non-lethal amount of Objective-C is used here.

### Multi Value Types

* AlternateBirthday
* MultiDate
* MultiString
* InstantMessageAddress
* PostalAddress
* SocialProfile

These "multi value types" are structs that represent the values in an `ABMultiValueRef`. As you may have guessed, `MultiDate` is a wrapper around `NSDate`, and `MultiString` for `String`. These exist for easy conversion between appropriate `CFTypeRef` values for addition to multi value objects and also for improved type safety.

### Protocols

* AddressBookType
* GroupType
* MultiValueRepresentable
* PersonType
* RecordType
* SourceType

`AddressBookType` enumerates the responsibilities and requirements of an address book object, and similar for `GroupType`, `PersonType`, and `SourceType`.

These protocols exist so you can use them in your app instead of concrete types. Why? The AddressBook framework is a black box and not easily testable. Now, you can use the `*Type` protocols to supply valid dummy data in your tests.

Instead of using an `ABAddressBookRef` internally, you can pass in an `AddressBookType`-conforming value into your class (via [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection)).

Before:

```swift
struct PersonViewModel {
    private let addressBook: ABAddressBookRef

    init() {
        // Create addressBook here
    }
}
```

After:

```swift
struct PersonViewModel<AB: AddressBookType> {
    private let addressBook: AB

    init(addressBook: AB) {
        // Assign addressBook here
    }
}
```

### Types

* **AddressBook, Group, Person, Record, Source:** Concrete implementations of the respective `*Type` protocols that are backed by `ABAddressBook` and `ABRecordRef` values.
* **AlternateBirthday:** A wrapper around `NSDateComponents`-like values.
* **LabeledValue:** A parameterized value that represents a type-safe view on a label and associated value.
* **Property, MutableProperty, et al.:** Lenses on the values contained in `RecordType` values.

## Availability

Gulliver is intended for Swift 1.2. Compatibility with future versions is not guaranteed.

## Gulliver?

"Gulliver" is the main character's name in *Travels into Several Remote Nations of the World. In Four Parts. By Lemuel Gulliver, First a Surgeon, and then a Captain of Several Ships* (commonly known as *Gulliver's Travels*), a satirical novel by Jonathan Swift (a Swift famous long before Taylor).
