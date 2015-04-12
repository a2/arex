import AddressBook
import Lustre

public final class Group: Record, GroupType {
    public typealias PersonState = ABRecordRef
    public typealias SourceState = ABRecordRef

    public required init(state: ABRecordRef) {
        precondition(RecordKind(rawValue: ABRecordGetRecordType(state)) == .Group, "ABRecordRef \(state) is not a group")
        super.init(state: state)
    }

    public convenience init() {
        let state: ABRecordRef = ABGroupCreate().takeRetainedValue()
        self.init(state: state)
    }

    public func source<S: _SourceType where S.State == SourceState>() -> S {
        let sourceState: ABRecordRef = ABGroupCopySource(state).takeRetainedValue()
        return S(state: sourceState)
    }

    public func allMembers<P: _PersonType where P.State == PersonState>() -> [P] {
        let array = ABGroupCopyArrayOfAllMembers(state).takeRetainedValue() as [ABRecordRef]
        return array.map({ P(state: $0) })
    }

    public func allMembers<P: _PersonType where P.State == PersonState>(sortOrdering: SortOrdering) -> [P] {
        let array = ABGroupCopyArrayOfAllMembersWithSortOrdering(state, sortOrdering.rawValue).takeRetainedValue() as [ABRecordRef]
        return array.map({ P(state: $0) })
    }

    public func add<P: _PersonType where P.State == PersonState>(member: P) -> VoidResult {
        var error: Unmanaged<CFErrorRef>? = nil
        if ABGroupAddMember(state, member.state, &error) {
            return success()
        } else if let error = error {
            return failure(error.takeUnretainedValue())
        } else {
            return failure("An unknown error occurred.")
        }
    }

    public func remove<P: _PersonType where P.State == PersonState>(member: P) -> VoidResult {
        var error: Unmanaged<CFErrorRef>? = nil
        if ABGroupRemoveMember(state, member.state, &error) {
            return success()
        } else if let error = error {
            return failure(error.takeUnretainedValue())
        } else {
            return failure("An unknown error occurred.")
        }
    }
}

public struct GroupProperty {
    public static let Name = MutableProperty<String>(propertyID: kABGroupNameProperty)
}
