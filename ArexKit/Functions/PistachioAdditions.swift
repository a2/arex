import LlamaKit
import Pistachio
import ReactiveCocoa

public func lift<A, B>(lens: Lens<Result<A, NoError>, Result<B, NoError>>) -> Lens<A, B> {
    let get: A -> B = { a in
        return Pistachio.get(lens, success(a)).value ?? undefined("lens cannot return failures")
    }

    let set: (A, B) -> A = { a, b in
        return Pistachio.set(lens, success(a), success(b)).value ?? undefined("lens cannot return failures")
    }

    return Lens(get: get, set: set)
}

public func transform<A, B, C>(lens: Lens<A, B>, valueTransformer: ValueTransformer<B, C, NoError>) -> Lens<A, C> {
    let get: A -> C = { a in
        let b = Pistachio.get(lens, a)
        return valueTransformer.transformedValue(b).value ?? undefined("valueTransformer cannot return failures")
    }

    let set: (A, C) -> A = { a, c in
        let b = valueTransformer.reverseTransformedValue(c) ?? undefined("valueTransformer cannot return failures")
        return Pistachio.set(lens, a, b)
    }

    return Lens(get: get, set: set)
}
