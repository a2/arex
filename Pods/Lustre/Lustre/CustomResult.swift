//
//  CustomResult.swift
//  Lustre
//
//  Created by Zachary Waldowski on 2/7/15.
//  Copyright (c) 2014-2015. All rights reserved.
//

import Foundation

// MARK: Protocols

/// A custom result type that can be created with some kind of success value.
public protocol CustomResult: ResultType {
    
    /// Creates a result in a success state.
    init(_ success: Value)

}

// MARK: Remote map/flatMap

extension VoidResult {

    /// Return the result of mapping a value `transform` over `self`.
    public func map<R: CustomResult>(@noescape getValue: () -> R.Value) -> R {
        switch self {
        case Success:            return success(getValue())
        case Failure(let error): return failure(error)
        }
    }

}

extension ObjectResult {

    /// Return the result of mapping a value `transform` over `self`.
    public func map<R: CustomResult>(@noescape transform: T -> R.Value) -> R {
        switch self {
        case Success(let value): return success(transform(value))
        case Failure(let error): return failure(error)
        }
    }

}

extension AnyResult {

    /// Return the result of mapping a value `transform` over `self`.
    public func map<R: CustomResult>(@noescape transform: T -> R.Value) -> R {
        switch self {
        case Success(let value): return success(transform(value as! T))
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

/**
    Wrap the result of a Cocoa-style function signature returning its value via
    output parameter into a result type, either through currying or inline with
    a trailing closure.

    :param: file A statically-known version of the calling file in the project.
    :param: line A statically-known version of the calling line in code.
    :param: makeError A transform to wrap the resulting error, such as in a
                      custom domain or with extra context.
    :param: fn A function with a Cocoa-style signature of many output pointers.
    :returns: A result type created by wrapping the returned byref value.
**/
public func try<R: CustomResult>(file: StaticString = __FILE__, line: UWord = __LINE__, @noescape makeError transform: (NSError -> NSError) = identityError, @noescape fn: (UnsafeMutablePointer<R.Value>, NSErrorPointer) -> Bool) -> R {
    var value: R.Value!
    var err: NSError?
    
    let didSucceed = withUnsafeMutablePointer(&value) { (ptr) -> Bool in
        bzero(UnsafeMutablePointer(ptr), sizeof(ImplicitlyUnwrappedOptional<R.Value>))
        return fn(UnsafeMutablePointer(ptr), &err)
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

/// Return the result of mapping a value `transform` over `result`.
public func map<IR: ResultType, RR: CustomResult>(result: IR, @noescape transform: IR.Value -> RR.Value) -> RR {
    if result.isSuccess {
        return success(transform(result.value))
    } else {
        return failure(result.error!)
    }
}

// MARK: Generic free constructors

/// A success result type returning `value`.
public func success<R: CustomResult>(value: R.Value) -> R {
    return R(value)
}
