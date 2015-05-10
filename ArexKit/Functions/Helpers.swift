/**
    Returns the Boolean value of the input

    :param: value A Boolean type

    :returns: The Bool value of the input
*/
public func boolValue<T: BooleanType>(value: T) -> Bool {
    return value.boolValue
}

/**
    Negates a Boolean-returning transformer.

    :param: transform The transformer to negate.

    :returns: The negated transformer.
*/
public func not<T, B: BooleanType>(transform: T -> B) -> T -> Bool {
    return { !transform($0) }
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
public func undefined<T>(_ hint: String = "", file: StaticString = __FILE__, line: UWord = __LINE__) -> T {
    let message = hint == "" ? "" : ": \(hint)"
    fatalError("undefined \(T.self)\(message)", file: file, line: line)
}

/// A no-op function.
public func void() { }

/// A no-op function that accepts a parameter of arbitrary type.
public func void<T>(value: T) { }
