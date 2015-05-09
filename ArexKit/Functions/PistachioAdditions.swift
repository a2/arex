import Monocle
import Pistachio
import ReactiveCocoa
import Result
import ValueTransformer

public func lift<A, B>(lens: Lens<Result<A, NoError>, Result<B, NoError>>) -> Lens<A, B> {
    let getter: A -> B = { a in
        return get(lens, Result(value: a)).value ?? undefined("lens cannot return failures")
    }

    let setter: (A, B) -> A = { a, b in
        return set(lens, Result(value: a), Result(value: b)).value ?? undefined("lens cannot return failures")
    }

    return Lens(get: getter, set: setter)
}

public func map<A, V: ReversibleValueTransformerType where V.ErrorType == NoError>(lens: Lens<A, V.ValueType>, reversibleValueTransformer: V) -> Lens<A, V.TransformedValueType> {
    let getter: A -> V.TransformedValueType = { a in
        let value = get(lens, a)
        return reversibleValueTransformer.transform(value) ?? undefined("reversibleValueTransformer cannot fail")
    }

    let setter: (A, V.TransformedValueType) -> A = { a, tv in
        let value: V.ValueType = reversibleValueTransformer.reverseTransform(tv) ?? undefined("reversibleValueTransformer cannot fail")
        return set(lens, a, value)
    }

    return Lens(get: getter, set: setter)
}
