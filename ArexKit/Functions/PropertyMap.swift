import ReactiveCocoa

private struct MappedProperty<T>: PropertyType {
    let _value: () -> T
    let _producer: () -> SignalProducer<T, NoError>

    var value: T {
        return _value()
    }

    var producer: SignalProducer<T, NoError> {
        return _producer()
    }

    init<P: PropertyType>(property: P, transform: P.Value -> T) {
        _value = { transform(property.value) }
        _producer = { property.producer |> ReactiveCocoa.map(transform) }
    }
}

extension PropertyType {
    /// Maps a property from one type to another.
    ///
    /// - parameter transform: The transform to apply.
    ///
    /// - returns: A property of the new type.
    public func map<T>(transform: Value -> T) -> PropertyOf<T> {
        return PropertyOf(MappedProperty(property: self, transform: transform))
    }
}
