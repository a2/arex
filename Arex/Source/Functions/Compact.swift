/**
    Prepares `value` for flattening.

    :param: value The value to filter.

    :returns: An `Array` containing either one element (if value is non-`nil`)
    or zero elements (if value is `nil`).
*/
func compact<T>(value: T?) -> [T] {
    if let value = value {
        return [value]
    } else {
        return []
    }
}

/**
    Prepares `value` for flattening.

    :param: value The value to filter.

    :returns: A `ContiguousArray` containing either one element (if value is non-`nil`)
    or zero elements (if value is `nil`).
*/
func compact<T>(value: T?) -> ContiguousArray<T> {
    if let value = value {
        return [value]
    } else {
        return []
    }
}

/**
    Prepares `value` for flattening.

    :param: value The value to filter.

    :returns: An `ArraySlice` containing either one element (if value is non-`nil`)
    or zero elements (if value is `nil`).
*/
func compact<T>(value: T?) -> ArraySlice<T> {
    if let value = value {
        return [value]
    } else {
        return []
    }
}

/**
    Filters `nil` elements from an array slice.

    :param: source The array slice to filter.

    :returns: An `ArraySlice` containing the non-`nil` elements of `source`.
*/
func compact<T>(source: [T?]) -> [T] {
    return source.flatMap(compact)
}

/**
    Filters `nil` elements from a contiguous array.

    :param: source The contiguous array to filter.

    :returns: A `ContiguousArray` containing the non-`nil` elements of `source`.
*/
func compact<T>(source: ContiguousArray<T?>) -> ContiguousArray<T> {
    return source.flatMap(compact)
}

/**
    Filters `nil` elements from an array slice.

    :param: source The array slice to filter.

    :returns: An `ArraySlice` containing the non-`nil` elements of `source`.
*/
func compact<T>(source: ArraySlice<T?>) -> ArraySlice<T> {
    return source.flatMap(compact)
}

/**
    Filters `nil` elements from a sequence.

    :param: source The sequence to filter.

    :returns: An `Array` containing the non-`nil` elements of `source`.
*/
func compact<S: SequenceType, T where S.Generator.Element == T?>(source: S) -> [T] {
    return flatMap(source, compact)
}

/**
    Filters `nil` elements from a collection.

    :param: source The collection to filter.

    :returns: An `Array` containing the non-`nil` elements of `source`, in order.
*/
func compact<C: CollectionType, T where C.Generator.Element == T?>(source: C) -> [T] {
    return flatMap(source, compact)
}
