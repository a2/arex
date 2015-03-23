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
    `undefined()` pretends to be able to produce a value of any type `T` which can
    be very useful whilst writing a program. It happens that you need a value
    (which can be a function as well) of a certain type but you can't produce it
    just yet. However, you can always temporarily replace it by `undefined()`.

    Inspired by Haskell's
    [undefined](http://hackage.haskell.org/package/base-4.7.0.2/docs/Prelude.html#v:undefined).

    Invoking `undefined()` will crash your program.

    Some examples:

     - `let x : String = undefined()`
     - `let f : String -> Int? = undefined("string to optional int function")`
     - `return undefined() /* in any function */`
     - `let x : String = (undefined() as Int -> String)(42)`
     - ...

    What a crash looks like:

    `fatal error: undefined: main.swift, line 131`

    Thanks to Johannes Weiß <https://github.com/weissi/swift-undefined>.
 */
func undefined<T>(_ hint: String = "", file: StaticString = __FILE__, line: UWord = __LINE__) -> T {
    let message = hint.isEmpty ? "" : " \(hint)"
    fatalError("undefined\(message)", file: file,  line:line)
}

/// A no-op function.
func void() { }

/// A no-op function that accepts a parameter of arbitrary type.
func void<T>(value: T) { }
