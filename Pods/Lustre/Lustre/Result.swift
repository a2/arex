//
//  Result.swift
//  Lustre
//
//  Created by Zachary Waldowski on 2/7/15.
//  Copyright (c) 2014-2015. All rights reserved.
//

import Foundation

/// A type that can reflect an either-or state for a given event, though not
/// necessarily mutually exclusively due to limitations in Swift. Ideally,
/// implementations of this type are an `enum` with two cases.
public protocol ResultType {
    
    /// Any contained value returns from the event.
    typealias Value
    
    /// Creates a result in a failure state
    init(failure: NSError)
    
    /// Returns true if the event succeeded.
    var isSuccess: Bool { get }
    
    /// The value contained by this result. If `isSuccess` is `true`, this
    /// should not be `nil`.
    var value: Value! { get }
    
    /// The error object iff the event failed and `isSuccess` is `false`.
    var error: NSError? { get }
    
    /// Return the Result of mapping `transform` over `self`.
    func flatMap<Result: ResultType>(@noescape transform: Value -> Result) -> Result

}

// MARK: Operators

/// Note that while it is possible to use `==` on results that contain an
/// `Equatable` type, results cannot themselves be `Equatable`. This is because
/// `T` may not be `Equatable`, and there is no way yet in Swift to define
/// define protocol conformance based on specialization.
public func == <LResult: ResultType, RResult: ResultType where LResult.Value: Equatable, RResult.Value == LResult.Value>(lhs: LResult, rhs: RResult) -> Bool {
    switch (lhs.isSuccess, rhs.isSuccess) {
    case (true, true): return lhs.value == rhs.value
    case (false, false): return lhs.error == rhs.error
    default: return false
    }
}

/// Same rules apply as `==`.
public func != <LResult: ResultType, RResult: ResultType where LResult.Value: Equatable, RResult.Value == LResult.Value>(lhs: LResult, rhs: RResult) -> Bool {
    switch (lhs.isSuccess, rhs.isSuccess) {
    case (true, true): return lhs.value != rhs.value
    case (false, false): return lhs.error != rhs.error
    default: return false
    }
}

/// Note that while it is possible to use `==` on results that contain an
/// `Equatable` type, results cannot themselves be `Equatable`. This is because
/// `T` may not be `Equatable`, and there is no way yet in Swift to define
/// define protocol conformance based on specialization.
public func == <Result: ResultType where Result.Value: Equatable>(lhs: Result, rhs: Result) -> Bool {
    switch (lhs.isSuccess, rhs.isSuccess) {
    case (true, true): return lhs.value == rhs.value
    case (false, false): return lhs.error == rhs.error
    default: return false
    }
}

/// Same rules apply as `==`.
public func != <Result: ResultType where Result.Value: Equatable>(lhs: Result, rhs: Result) -> Bool {
    switch (lhs.isSuccess, rhs.isSuccess) {
    case (true, true): return lhs.value != rhs.value
    case (false, false): return lhs.error != rhs.error
    default: return false
    }
}

/// Result failure coalescing
///    success(42) ?? 0 ==> 42
///    failure(error()) ?? 0 ==> 0
public func ??<Result: ResultType>(result: Result, @autoclosure defaultValue: () -> Result.Value) -> Result.Value {
    return result.value ?? defaultValue()
}

// MARK: Pattern matching

public func ~=<Inner: ResultType, Outer: ResultType where Inner.Value: Equatable, Inner.Value == Outer.Value>(lhs: Inner, rhs: Outer) -> Bool {
    switch (lhs.isSuccess, rhs.isSuccess) {
    case (true, true): return lhs.value == rhs.value
    case (false, false): return lhs.error == rhs.error
    default: return false
    }
}

public func ~=<R: ResultType>(lhs: VoidResult, rhs: R) -> Bool {
    switch (lhs.isSuccess, rhs.isSuccess) {
    case (true, true): return true
    case (false, false): return lhs.error == rhs.error
    default: return false
    }
}

// MARK: Generic free initializers

public func failure<Result: ResultType>(error: NSError) -> Result {
    return Result(failure: error)
}

public func failure<Result: ResultType>(_ message: String? = nil, file: StaticString = __FILE__, line: UWord = __LINE__) -> Result {
    return Result(failure: error(message, file: file, line: line))
}
