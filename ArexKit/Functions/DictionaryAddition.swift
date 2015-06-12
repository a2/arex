public func +<K, V>(var lhs: [K : V], rhs: [K : V]) -> [K : V] {
    for (key, val) in rhs {
        lhs[key] = val
    }

    return lhs
}

public func +=<K, V>(inout lhs: [K : V], rhs: [K : V]) {
    for (key, val) in rhs {
        lhs[key] = val
    }
}
