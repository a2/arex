import Lustre

public protocol _RecordType: StateRepresentable {}

public protocol RecordType: _RecordType {
    var recordID: RecordID { get }
    var recordKind: RecordKind { get }

    func value<P: ReadablePropertyType>(forProperty property: P) -> P.ValueType?

    func setValue<P: WritablePropertyType>(value: P.ValueType?, forProperty property: P) -> VoidResult
}
