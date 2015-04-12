import Foundation
import Lustre

func failure<Result: ResultType>(error: CFErrorRef) -> Result {
    return Result(failure: unsafeBitCast(error, NSError.self))
}
