public func +<K, V>(lhs: [K : V], rhs: [K : V]) -> [K : V] {
    var result = lhs
    for (key, val) in rhs {
        result[key] = val
    }

    return result
}

public func +=<K, V>(inout lhs: [K : V], rhs: [K : V]) {
    for (key, val) in rhs {
        lhs[key] = val
    }
}
