import AddressBook
import Foundation
import Lustre

public func localizedLabel(label: String) -> String? {
    if let value = ABAddressBookCopyLocalizedLabel(label) {
        return value.takeRetainedValue() as String
    } else {
        return nil
    }
}

public func systemAddressBook() -> ObjectResult<AddressBook> {
    var error: Unmanaged<CFErrorRef>? = nil
    if let addressBook = ABAddressBookCreateWithOptions(nil, &error) {
        return success(AddressBook(state: addressBook.takeRetainedValue()))
    } else if let error = error {
        return failure(error.takeUnretainedValue())
    } else {
        return failure("An unknown error occurred.")
    }
}

public final class AddressBook: AddressBookType {
    public typealias RecordState = ABRecordRef
    public typealias PersonState = ABRecordRef
    public typealias GroupState = ABRecordRef
    public typealias SourceState = ABRecordRef

    private class Observer: ExternalChangeObserver {
        var handler: (Void -> Void)?

        init(handler: Void -> Void) {
            self.handler = handler
        }

        deinit {
            assert(handler == nil, "AddressBook observer was not unregistered before deinitialization")
        }

        func stopObserving() {
            handler?()
            handler = nil
        }
    }

    public let state: ABAddressBookRef

    public init(state: ABAddressBookRef) {
        self.state = state
    }

    public static var authorizationStatus: AuthorizationStatus {
        return AuthorizationStatus(rawValue: ABAddressBookGetAuthorizationStatus())!
    }

    public func requestAccess(completionHandler: VoidResult -> Void) {
        ABAddressBookRequestAccessWithCompletion(state) { hasAccess, error in
            if hasAccess {
                completionHandler(success())
            } else if let error = error {
                completionHandler(failure(error))
            } else {
                completionHandler(failure("An unknown error occurred."))
            }
        }
    }

    public var hasUnsavedChanges: Bool {
        return ABAddressBookHasUnsavedChanges(state)
    }

    public func save() -> VoidResult {
        var error: Unmanaged<CFErrorRef>? = nil
        if ABAddressBookSave(state, &error) {
            return success()
        } else if let error = error {
            return failure(error.takeUnretainedValue())
        } else {
            return failure("An unknown error occurred.")
        }
    }

    public func observeExternalChanges(var callback: ExternalChangeHandler) -> ExternalChangeObserver {
        ABAddressBookRegisterExternalChangeCallback(state, GLVExternalChangeCallback, &callback)
        return Observer { [weak self] in
            if let state: ABAddressBookRef = self?.state {
                ABAddressBookUnregisterExternalChangeCallback(state, GLVExternalChangeCallback, &callback)
            }
        }
    }

    public func addRecord<R: _RecordType where R.State == RecordState>(record: R) -> VoidResult {
        var error: Unmanaged<CFErrorRef>? = nil
        if ABAddressBookAddRecord(state, record.state, &error) {
            return success()
        } else if let error = error {
            return failure(error.takeUnretainedValue())
        } else {
            return failure("An unknown error occurred.")
        }
    }

    public func removeRecord<R: _RecordType where R.State == RecordState>(record: R) -> VoidResult {
        var error: Unmanaged<CFErrorRef>? = nil
        if ABAddressBookRemoveRecord(state, record.state, &error) {
            return success()
        } else if let error = error {
            return failure(error.takeUnretainedValue())
        } else {
            return failure("An unknown error occurred.")
        }
    }

    // MARK: - People

    public var personCount: Int {
        return ABAddressBookGetPersonCount(state)
    }

    public func person<P: _PersonType where P.State == PersonState>(recordID: RecordID) -> P? {
        if let record = ABAddressBookGetPersonWithRecordID(state, recordID) {
            return P(state: record.takeUnretainedValue())
        } else {
            return nil
        }
    }

    public func people<P: _PersonType where P.State == PersonState>(name: String) -> [P] {
        if let people = ABAddressBookCopyPeopleWithName(state, name) {
            let states = people.takeRetainedValue() as [ABRecordRef]
            return states.map({ P(state: $0) })
        } else {
            return []
        }
    }

    public func allPeople<P: _PersonType, S: _SourceType where P.State == PersonState, S.State == SourceState>(source: S) -> [P] {
        if let people = ABAddressBookCopyArrayOfAllPeopleInSource(state, source.state) {
            let records = people.takeRetainedValue() as [ABRecordRef]
            return records.map({ P(state: $0) })
        } else {
            return []
        }
    }

    public func allPeople<P: _PersonType, S: _SourceType where P.State == PersonState, S.State == SourceState>(source: S, sortOrdering: SortOrdering) -> [P] {
        if let people = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(state, source.state, sortOrdering.rawValue) {
            let states = people.takeRetainedValue() as [ABRecordRef]
            return states.map({ P(state: $0) })
        } else {
            return []
        }
    }

    // MARK: - Groups

    public var groupCount: Int {
        return ABAddressBookGetGroupCount(state)
    }

    public func group<G: _GroupType where G.State == GroupState>(recordID: RecordID) -> G? {
        if let record = ABAddressBookGetGroupWithRecordID(state, recordID) {
            return G(state: record.takeUnretainedValue())
        } else {
            return nil
        }
    }

    public func allGroups<G: _GroupType where G.State == GroupState>() -> [G] {
        if let array = ABAddressBookCopyArrayOfAllGroups(state) {
            let groups = array.takeRetainedValue() as [ABRecordRef]
            return groups.map({ G(state: $0) })
        } else {
            return []
        }
    }

    public func allGroups<G: _GroupType, S: _SourceType where G.State == GroupState, S.State == SourceState>(source: S) -> [G] {
        if let records = ABAddressBookCopyArrayOfAllGroupsInSource(state, source.state) {
            let array = records.takeRetainedValue() as [ABRecordRef]
            return array.map({ G(state: $0) })
        } else {
            return []
        }
    }

    // MARK: - Sources

    public func defaultSource<S: _SourceType where S.State == SourceState>() -> S {
        let sourceState: ABRecordRef = ABAddressBookCopyDefaultSource(state).takeRetainedValue()
        return S(state: sourceState)
    }

    public func source<S: _SourceType where S.State == SourceState>(recordID: RecordID) -> S? {
        if let record = ABAddressBookGetSourceWithRecordID(state, recordID) {
            return S(state: record.takeUnretainedValue())
        } else {
            return nil
        }
    }

    public func allSources<S: _SourceType where S.State == SourceState>() -> [S] {
        if let array = ABAddressBookCopyArrayOfAllSources(state) {
            let states = array.takeRetainedValue() as [ABRecordRef]
            return states.map({ S(state: $0) })
        } else {
            return []
        }
    }
}
