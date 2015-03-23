import ReactiveCocoa

/**
    Returns the Boolean value of the input

    :param: value A Boolean type

    :returns: The Bool value of the input
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
    Maps a `PropertyType` from one type to another.

    :param: property The property to map.
    :param: transform The transform to apply.

    :returns: A property of a new type.
*/
func map<P: PropertyType, T>(property: P, transform: P.Value -> T) -> PropertyOf<T> {
    var mutableProperty = MutableProperty<T>(transform(property.value))
    property.producer
        |> map(transform)
        |> start(Event.sink(next: mutableProperty.put))
    return PropertyOf(mutableProperty)
}

/**
    Negates the input.

    :param: value A Boolean type.

    :returns: The negated Boolean value.
*/
func not<T: BooleanType>(value: T) -> Bool {
    return !value.boolValue
}

/**
    Negates a Boolean-returning transformer.

    :param: transform The transformer to negate.

    :returns: The negated transformer.
*/
func not<T, B: BooleanType>(transform: T -> B) -> T -> Bool {
    return { !transform($0) }
}

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
    `undefined` fills holes.

    Thanks to Johannes Weiß <https://speakerdeck.com/johannesweiss/further-leveraging-the-type-system>.

    :param: message An optional message to print when evaluated. It should complete the phrase: "This is impossible because..."

    :returns: Raises an assertion
*/
func undefined<T>(_ message: String = "", file: StaticString = __FILE__, line: UWord = __LINE__) -> T {
    fatalError("undefined \(message)", file: file, line: line)
}

/// A no-op function.
func void() { }

/// A no-op function that accepts a parameter of arbitrary type.
func void<T>(value: T) { }
