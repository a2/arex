import ReactiveCocoa

/**
    Returns the boolean value of the input

    :param: value A boolean type

    :returns: The boolean value of the input
*/
func boolValue<T: BooleanType>(value: T) -> Bool {
    return value.boolValue
}

/**
    Handles an error by discarding it.

    :param: error The error to "handle".

    :returns: An empty signal producer.
*/
func catchAll<T, E>(error: E) -> SignalProducer<T, NoError> {
    return .empty
}

/**
    A function that accepts a parameter of arbitrary type and does nothing with it.

    :param: value A value to ignore.
*/
func gobble<T>(value: T) { }

/**
    A function that accepts a parameter of arbitrary type and replaces it with a second value of arbitrary type.

    :param: value A value to ignore.
    :param: replacement A constant value to return.

    :returns: `replacement`
*/
func replace<T, U>(replacement: T)(value: U) -> T {
    return replacement
}

/**
    Negates the input

    :param: value A boolean type

    :returns: The negated boolean value
*/
func not<T: BooleanType>(value: T) -> Bool {
    return !value.boolValue
}
