import Foundation
import Pistachio
import ValueTransformer

struct DateTransformers {
    static func timeIntervalSinceReferenceDate<E>() -> ReversibleValueTransformer<NSDate, NSTimeInterval, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return .success(value.timeIntervalSinceReferenceDate)
        }, reverseTransformClosure: { value in
            return .success(NSDate(timeIntervalSinceReferenceDate: value))
        })
    }

    static func timeIntervalSince1970<E>() -> ReversibleValueTransformer<NSDate, NSTimeInterval, E> {
        return ReversibleValueTransformer(transformClosure: { value in
            return .success(value.timeIntervalSince1970)
        }, reverseTransformClosure: { value in
            return .success(NSDate(timeIntervalSince1970: value))
        })
    }
}
