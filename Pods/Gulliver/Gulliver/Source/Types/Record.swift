import AddressBook
import Foundation
import Lustre

public typealias RecordID = ABRecordID

public class Record: RecordType {
    public let state: ABRecordRef

    public required init(state: ABRecordRef) {
        self.state = state
    }

    public var recordID: RecordID {
        return ABRecordGetRecordID(state)
    }

    public var recordKind: RecordKind {
        return RecordKind(rawValue: ABRecordGetRecordType(state))!
    }

    public func value<P: ReadablePropertyType>(forProperty property: P) -> P.ValueType? {
        if let unmanagedValue = ABRecordCopyValue(state, property.propertyID) {
            let value: CFTypeRef = unmanagedValue.takeRetainedValue()
            return property.readTransform?(value) ?? (value as! P.ValueType)
        } else {
            return nil
        }
    }

    public func setValue<P: WritablePropertyType>(value: P.ValueType?, forProperty property: P) -> VoidResult {
        var error: Unmanaged<CFErrorRef>? = nil
        if let value = value {
            let transformedValue: CFTypeRef = property.writeTransform?(value) ?? (value as! CFTypeRef)
            if ABRecordSetValue(state, property.propertyID, transformedValue, &error) {
                return success()
            }
        } else {
            if ABRecordRemoveValue(state, property.propertyID, &error) {
                return success()
            }
        }

        if let error = error {
            return failure(error.takeUnretainedValue())
        } else {
            return failure("An unknown error occurred.")
        }
    }
}
