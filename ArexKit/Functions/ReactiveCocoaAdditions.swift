import ReactiveCocoa

/**
    Handles an error by discarding it.

    :param: error The error to "handle".

    :returns: An empty signal producer.
*/
public func catchAll<T, E>(error: E) -> SignalProducer<T, NoError> {
    return .empty
}

/**
    Maps a `PropertyType` from one type to another.

    :param: property The property to map.
    :param: transform The transform to apply.

    :returns: A property of a new type.
*/
public func map<P: PropertyType, T>(property: P, transform: P.Value -> T) -> PropertyOf<T> {
    var mutableProperty = MutableProperty<T>(transform(property.value))
    property.producer
        |> map(transform)
        |> start(Event.sink(next: mutableProperty.put))
    return PropertyOf(mutableProperty)
}

/**
    A function that accepts a parameter of arbitrary type and replaces it with a second value of arbitrary type.

    :param: value A value to ignore.
    :param: replacement A constant value to return.

    :returns: `replacement`
*/
public func replace<T, U>(replacement: T)(value: U) -> T {
    return replacement
}

/** Convenience function to add an optional Disposable to a CompositeDisposable. */
public func +=(disposable: CompositeDisposable, d: Disposable?) -> CompositeDisposable.DisposableHandle {
    return disposable.addDisposable(d)
}

/** Convenience function to add a disposal action to a CompositeDisposable. */
public func +=(disposable: CompositeDisposable, action: Void -> Void) -> CompositeDisposable.DisposableHandle {
    return disposable.addDisposable(action)
}
