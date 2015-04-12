//
//  CustomResult.swift
//  Lustre
//
//  Created by Zachary Waldowski on 2/7/15.
//  Copyright (c) 2014-2015. All rights reserved.
//

import Foundation

// MARK: Protocols

/// A custom result type that can be created with some kind of success value
public protocol CustomResult: ResultType {
    
    /// Creates a result in a success state
    init(_ success: Value)

}

// MARK: Remote map/flatMap

extension VoidResult {

    public func map<R: CustomResult>(@noescape getValue: () -> R.Value) -> R {
        switch self {
        case Success:            return success(getValue())
        case Failure(let error): return failure(error)
        }
    }

}

extension ObjectResult {

    public func map<R: CustomResult>(@noescape transform: T -> R.Value) -> R {
        switch self {
        case Success(let value): return success(transform(value))
        case Failure(let error): return failure(error)
        }
    }

}

extension AnyResult {

    public func map<R: CustomResult>(@noescape transform: T -> R.Value) -> R {
        switch self {
        case Success(let value): return success(transform(value as! T))
        case Failure(let error): return failure(error)
        }
    }

}

// MARK: Free try

public func try<R: CustomResult>(file: StaticString = __FILE__, line: UWord = __LINE__, @noescape makeError transform: (NSError -> NSError) = identityError, @noescape fn: NSErrorPointer -> R.Value?) -> R {
    var err: NSError?
    switch (fn(&err), err) {
    case (.Some(let value), _):
        return success(value)
    case (.None, .Some(let error)):
        return failure(transform(error))
    default:
        return failure(transform(error(file: file, line: line)))
    }
}

public func try<R: CustomResult>(file: StaticString = __FILE__, line: UWord = __LINE__, @noescape makeError transform: (NSError -> NSError) = identityError, @noescape fn: (UnsafeMutablePointer<R.Value>, NSErrorPointer) -> Bool) -> R {
    var value: R.Value!
    var err: NSError?
    
    let didSucceed = withUnsafeMutablePointer(&value) {
        fn(UnsafeMutablePointer($0), &err)
    }
    
    switch (didSucceed, err) {
    case (true, _):
        return success(value)
    case (false, .Some(let error)):
        return failure(transform(error))
    default:
        return failure(transform(error(file: file, line: line)))
    }
}

// MARK: Free maps

public func map<IR: ResultType, RR: CustomResult>(result: IR, @noescape transform: IR.Value -> RR.Value) -> RR {
    if result.isSuccess {
        return success(transform(result.value))
    } else {
        return failure(result.error!)
    }
}

// MARK: Generic free constructors

public func success<R: CustomResult>(value: R.Value) -> R {
    return R(value)
}
