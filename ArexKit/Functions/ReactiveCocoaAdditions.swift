import ReactiveCocoa

/// Handles an error by discarding it.
///
/// - parameter error: The error to "handle".
///
/// - returns: An empty signal producer.
public func catchAll<T, E>(error: E) -> SignalProducer<T, NoError> {
    return .empty
}

/// A function that accepts a parameter of arbitrary type and replaces it with a second value of arbitrary type.
///
/// - parameter value: An ignored value.
/// - parameter replacement: A constant value to return.
///
/// - returns: The replacement value.
public func replace<T, U>(replacement: T)(_: U) -> T {
    return replacement
}
