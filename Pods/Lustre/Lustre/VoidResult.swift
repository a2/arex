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

    public init(failure: NSError) {
        self = .Failure(failure)
    }

    public var isSuccess: Bool {
        switch self {
        case .Success: return true
        case .Failure: return false
        }
    }
    
    public var value: ()! {
        return ()
    }

    public var error: NSError? {
        switch self {
        case .Success: return nil
        case .Failure(let error): return error
        }
    }
    
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

extension VoidResult: Equatable {}

public func == (lhs: VoidResult, rhs: VoidResult) -> Bool {
    switch (lhs.isSuccess, rhs.isSuccess) {
    case (true, true): return true
    case (false, false): return lhs.error == rhs.error
    default: return false
    }
}

// MARK: Remote map/flatMap

extension VoidResult {

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

    public func map<U: AnyObject>(@noescape fn: T -> ()) -> VoidResult {
        switch self {
        case Success(let value):
            fn(value);
            return success()
        case Failure(let error): return failure(error)
        }
    }

}

extension AnyResult {

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

public func map<IR: ResultType>(result: IR, @noescape fn: IR.Value -> ()) -> VoidResult {
    if result.isSuccess {
        fn(result.value)
        return success()
    } else {
        return failure(result.error!)
    }
}

// MARK: Free constructors

public func success() -> VoidResult {
    return .Success
}
