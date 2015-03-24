import Foundation
import LlamaKit
import Pistachio

struct DateTransformers {
    static func timeIntervalSinceReferenceDate<E>() -> ValueTransformer<NSDate, NSTimeInterval, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.timeIntervalSinceReferenceDate)
        }, reverseTransformClosure: { value in
            return success(NSDate(timeIntervalSinceReferenceDate: value))
        })
    }

    static func timeIntervalSince1970<E>() -> ValueTransformer<NSDate, NSTimeInterval, E> {
        return ValueTransformer(transformClosure: { value in
            return success(value.timeIntervalSince1970)
        }, reverseTransformClosure: { value in
            return success(NSDate(timeIntervalSince1970: value))
        })
    }
}
