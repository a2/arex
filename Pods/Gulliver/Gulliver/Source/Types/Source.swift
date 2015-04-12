import AddressBook
import Lustre

public final class Source: Record, SourceType {
    public typealias PersonState = ABRecordRef
    public typealias GroupState = ABRecordRef

    public required init(state: ABRecordRef) {
        precondition(RecordKind(rawValue: ABRecordGetRecordType(state)) == .Source, "ABRecordRef \(state) is not a source")
        super.init(state: state)
    }

    private static let sourceKindProperty = Property<SourceKind>(propertyID: kABSourceTypeProperty, readTransform: readTransform)

    public var sourceKind: SourceKind {
        return value(forProperty: Source.sourceKindProperty)!
    }

    public func newPerson<P: _PersonType where P.State == PersonState>() -> P {
        let personState: ABRecordRef = ABPersonCreateInSource(state).takeRetainedValue()
        return P(state: personState)
    }

    public func newGroup<G: _GroupType where G.State == GroupState>() -> G {
        let groupState: ABRecordRef = ABGroupCreateInSource(state).takeRetainedValue()
        return G(state: groupState)
    }
}

public struct SourceProperty {
    public static let Name = MutableProperty<String>(propertyID: kABSourceNameProperty)
}
