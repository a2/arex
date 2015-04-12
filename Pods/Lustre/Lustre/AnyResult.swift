//
//  AnyResult.swift
//  Lustre
//
//  Created by Zachary Waldowski on 2/7/15.
//  Copyright (c) 2014-2015. All rights reserved.
//

import Foundation

/// Container for a successful value (`T`) or a failure (`NSError`).
/// Due to Swift limitations, the `.Success()` case is type-unsafe. Uses should
/// prefer `ObjectResult` or `CustomResult` instead, or use `value` exclusively.
public enum AnyResult<T> {
    case Success(Any)
    case Failure(NSError)
}

extension AnyResult: ResultType {

    public init(failure: NSError) {
        self = .Failure(failure)
    }

    public var isSuccess: Bool {
        switch self {
        case .Success: return true
        case .Failure: return false
        }
    }

    public var value: T! {
        switch self {
        case .Success(let value): return (value as! T)
        case .Failure: return nil
        }
    }

    public var error: NSError? {
        switch self {
        case .Success: return nil
        case .Failure(let error): return error
        }
    }

    public func flatMap<R: ResultType>(@noescape transform: T -> R) -> R {
        switch self {
            case Success(let value): return transform(value as! T)
            case Failure(let error): return failure(error)
        }
    }

}

extension AnyResult: Printable {

    /// A textual representation of `self`.
    public var description: String {
        switch self {
        case .Success(let value): return "Success: \(value as! T)"
        case .Failure(let error): return "Failure: \(error)"
        }
    }

}

// MARK: Remote map/flatMap

extension VoidResult {

    public func map<U>(@noescape getValue: () -> U) -> AnyResult<U> {
        switch self {
        case Success(let value): return success(getValue())
        case Failure(let error): return failure(error)
        }
    }

}

extension ObjectResult {

    public func map<U>(@noescape transform: T -> U) -> AnyResult<U> {
        switch self {
        case Success(let value): return success(transform(value))
        case Failure(let error): return failure(error)
        }
    }

}

extension AnyResult {

    public func map<U>(@noescape transform: T -> U) -> AnyResult<U> {
        switch self {
        case Success(let value): return success(transform(value as! T))
        case Failure(let error): return failure(error)
        }
    }

}

// MARK: Free try

public func try<T>(file: StaticString = __FILE__, line: UWord = __LINE__, @noescape makeError transform: (NSError -> NSError) = identityError, @noescape fn: NSErrorPointer -> T?) -> AnyResult<T> {
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

public func try<T>(file: StaticString = __FILE__, line: UWord = __LINE__, @noescape makeError transform: (NSError -> NSError) = identityError, @noescape fn: (UnsafeMutablePointer<T>, NSErrorPointer) -> Bool) -> AnyResult<T> {
    var value: T!
    var err: NSError?
    
    let didSucceed = withUnsafeMutablePointer(&value) { (ptr) -> Bool in
        bzero(UnsafeMutablePointer(ptr), sizeof(ImplicitlyUnwrappedOptional<T>))
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

public func map<IR: ResultType, U>(result: IR, @noescape transform: IR.Value -> U) -> AnyResult<U> {
    if result.isSuccess {
        return success(transform(result.value))
    } else {
        return failure(result.error!)
    }
}

// MARK: Free constructors

public func success<T>(value: T) -> AnyResult<T> {
    return .Success(value)
}
