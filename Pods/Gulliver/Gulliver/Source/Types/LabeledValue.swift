public typealias MultiValueIdentifier = ABMultiValueIdentifier
public let MultiValueIdentifierInvalid: MultiValueIdentifier = kABMultiValueInvalidIdentifier

public struct LabeledValue<T: MultiValueRepresentable>: DebugPrintable, Printable {
    public var label: String
    public var value: T

    public init(label: String, value: T) {
        self.label = label
        self.value = value
    }

    public var description: String {
        return "\(label): \(toString(value))"
    }

    public var debugDescription: String {
        return "\(label): \(toDebugString(value))"
    }

    public static func read(multiValue: ABMultiValueRef) -> [LabeledValue<T>] {
        assert(PropertyKind(rawValue: ABMultiValueGetPropertyType(multiValue)) == T.multiValueType, "ABMultiValueRef argument has incompatible property type")

        var labeledValues = [LabeledValue<T>]()
        let count: Int = ABMultiValueGetCount(multiValue)
        for i in 0..<count {
            let label = ABMultiValueCopyLabelAtIndex(multiValue, i).takeRetainedValue() as String

            let dictionaryRepresenation: CFTypeRef = ABMultiValueCopyValueAtIndex(multiValue, i).takeRetainedValue()
            let value = T(multiValueRepresentation: dictionaryRepresenation)!

            labeledValues.append(LabeledValue(label: label, value: value))
        }
        
        return labeledValues
    }

    public static func write(labeledValues: [LabeledValue<T>]) -> ABMultiValueRef {
        var result: ABMutableMultiValueRef = ABMultiValueCreateMutable(T.multiValueType.rawValue).takeRetainedValue()
        for labeledValue in labeledValues {
            ABMultiValueAddValueAndLabel(result, labeledValue.value.multiValueRepresentation, labeledValue.label, nil)
        }
        
        return result
    }
}
