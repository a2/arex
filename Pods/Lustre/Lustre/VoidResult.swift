//
//  VoidResult.swift
//  Lustre
//
//  Created by Zachary Waldowski on 2/7/15.
//  Copyright (c) 2014-2015. All rights reserved.
//

import Foundation

/// Container for an anonymous success or a failure (`NSError`)
public enum VoidResult {
    case Success
    case Failure(NSError)
}

extension VoidResult: ResultType {

    /// Creates a result in a failure state
    public init(failure: NSError) {
        self = .Failure(failure)
    }

    /// Returns true if the event succeeded.
    public var isSuccess: Bool {
        switch self {
        case .Success: return true
        case .Failure: return false
        }
    }
    
    /// The value contained by this result. If `isSuccess` is `true`, this
    /// should not be `nil`.
    public var value: ()! {
        return ()
    }

    /// The error object iff the event failed and `isSuccess` is `false`.
    public var error: NSError? {
        switch self {
        case .Success: return nil
        case .Failure(let error): return error
        }
    }
    
    /// Return the result of mapping a result `transform` over `self`.
    public func flatMap<R: ResultType>(@noescape transform: () -> R) -> R {
        switch self {
        case .Success: return transform()
        case .Failure(let error): return failure(error)
        }
    }

}

extension VoidResult: Printable {

    /// A textual representation of `self`.
    public var description: String {
        switch self {
        case .Success(let value): return "Success: ()"
        case .Failure(let error): return "Failure: \(error)"
        }
    }

}

/**
    Unlike result types on the whole, all `VoidResult`s are inherently
    equatable.

    :returns: `true` if both results are successes, or if they both contain
    identical errors.
**/
public func == (lhs: VoidResult, rhs: VoidResult) -> Bool {
    switch (lhs.isSuccess, rhs.isSuccess) {
    case (true, true): return true
    case (false, false): return lhs.error == rhs.error
    default: return false
    }
}

extension VoidResult: Hashable {

    /// An integer hash value describing a unique instance.
    public var hashValue: Int {
        switch self {
        case .Success:            return 0
        case .Failure(let error): return error.hash
        }
    }

}

// MARK: Remote map/flatMap

extension VoidResult {

    /// Return the result of executing a function if `self` was successful.
    public func map(@noescape fn: () -> ()) -> VoidResult {
        switch self {
        case Success:
            fn();
            return success()
        case Failure(let error): return failure(error)
        }
    }

}

extension ObjectResult {

    /// Return the result of executing a function if `self` was successful.
    public func map<U: AnyObject>(@noescape fn: T -> ()) -> VoidResult {
        switch self {
        case Success(let value):
            fn(value)
            return success()
        case Failure(let error): return failure(error)
        }
    }

}

extension AnyResult {

    /// Return the result of executing a function if `self` was successful.
    public func map(@noescape fn: T -> ()) -> VoidResult {
        switch self {
        case Success(let value):
            fn(value as! T);
            return success()
        case Failure(let error): return failure(error)
        }
    }

}

// MARK: Free try

/**
    Wrap the result of a Cocoa-style function signature into a result type,
    either through currying or inline with a trailing closure.

    :param: file A statically-known version of the calling file in the project.
    :param: line A statically-known version of the calling line in code.
    :param: makeError A transform to wrap the resulting error, such as in a
                      custom domain or with extra context.
    :param: fn A function with a Cocoa-style `NSErrorPointer` signature.
    :returns: A result type created by wrapping the returned optional.
**/
public func try(file: StaticString = __FILE__, line: UWord = __LINE__, @noescape makeError transform: (NSError -> NSError) = identityError, @noescape fn: NSErrorPointer -> Bool) -> VoidResult {
    var err: NSError?
    switch (fn(&err), err) {
    case (true, _):
        return success()
    case (false, .Some(let error)):
        return failure(transform(error))
    default:
        return failure(transform(error(file: file, line: line)))
    }
}

// MARK: Free maps

/// Return the result of executing a function if `result` was successful.
public func map<IR: ResultType>(result: IR, @noescape fn: IR.Value -> ()) -> VoidResult {
    if result.isSuccess {
        fn(result.value)
        return success()
    } else {
        return failure(result.error!)
    }
}

// MARK: Free constructors

/// A success `VoidResult`.
public func success() -> VoidResult {
    return .Success
}
