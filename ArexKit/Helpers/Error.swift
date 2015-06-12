/// Originally written by Zachary Waldowski for URLGrey.
/// https://github.com/zwaldowski/URLGrey

import Foundation

public protocol ErrorRepresentable: CustomStringConvertible {
    typealias ErrorCode: SignedIntegerType

    static var domain: String { get }
    var code: ErrorCode { get }
    var failureReason: String? { get }
}

public func error<T: ErrorRepresentable>(code code: T, underlying: NSError? = nil) -> NSError {
    var userInfo = [NSObject: AnyObject]()
    userInfo[NSLocalizedDescriptionKey] = code.description
    
    if let reason = code.failureReason {
        userInfo[NSLocalizedFailureReasonErrorKey] = reason
    }
    
    if let underlying = underlying {
        userInfo[NSUnderlyingErrorKey] = underlying
    }
    
    return NSError(domain: T.domain, code: numericCast(code.code), userInfo: userInfo)
}
