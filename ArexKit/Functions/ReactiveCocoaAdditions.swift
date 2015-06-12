import ReactiveCocoa

/// Handles an error by discarding it.
///
/// - parameter error: The error to "handle".
///
/// - returns: An empty signal producer.
public func catchAll<T, E>(error: E) -> SignalProducer<T, NoError> {
    return .empty
}

/// Maps a `PropertyType` from one type to another.
///
/// - parameter property: The property to map.
/// - parameter transform: The transform to apply.
///
/// - returns: A property of a new type.
public func map<P: PropertyType, T>(property: P, _ transform: P.Value -> T) -> PropertyOf<T> {
    let mutableProperty = MutableProperty<T>(transform(property.value))
    property.producer
        |> map(transform)
        |> start(Event.sink(next: mutableProperty.put))
    return PropertyOf(mutableProperty)
}

/// A function that accepts a parameter of arbitrary type and replaces it with a second value of arbitrary type.
///
/// - parameter value: A value to ignore.
/// - parameter replacement: A constant value to return.
///
/// - returns: `replacement`
public func replace<T, U>(replacement: T)(value: U) -> T {
    return replacement
}

/// Promotes a signal that does not generate values into one that can.
///
/// This does not actually cause values to be generated for the given signal,
/// but makes it easier to combine with other signals that may send values.
public func promoteValues<T, E: ReactiveCocoa.ErrorType>(_: T.Type)(signal: Signal<Void, E>) -> Signal<T, E> {
    return signal |> map { return undefined("Did not expect signal to send a next event") }
}
