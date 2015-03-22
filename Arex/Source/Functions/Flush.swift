func flush<T: Equatable>(value: T, invalid: T) -> T? {
    if value != invalid {
        return value
    } else {
        return nil
    }
}

func flush<T: Equatable>(value: T?, invalid: T) -> T? {
    if let value = value where value != invalid {
        return value
    } else {
        return nil
    }
}

func flush<T: Equatable, C: CollectionType where C.Generator.Element == T>(value: T, validValues: C) -> T? {
    if find(validValues, value) != nil {
        return value
    } else {
        return nil
    }
}

func flush<T: Equatable, C: CollectionType where C.Generator.Element == T>(value: T?, validValues: C) -> T? {
    if let value = value where find(validValues, value) != nil {
        return value
    } else {
        return nil
    }
}

func not<T, B: BooleanType>(validator: T -> B) -> T -> Bool {
    return { value in
        return !validator(value)
    }
}

func flush<T, B: BooleanType>(value: T, validator: T -> B) -> T? {
    if validator(value) {
        return value
    } else {
        return nil
    }
}

func flush<T, B: BooleanType>(value: T?, validator: T -> B) -> T? {
    switch value {
    case .Some(let value) where validator(value):
        return value
    default:
        return nil
    }
}
