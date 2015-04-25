//
//  Error.swift
//  Lustre
//
//  Created by Zachary Waldowski on 12/10/14.
//  Copyright (c) 2014-2015. All rights reserved.
//

import Foundation

/// An enumerable type with the requisite information to create an `NSError`.
public protocol ErrorRepresentable: Printable {
    typealias ErrorCode: SignedIntegerType

    /**
        An arbitrary string to differentiate groups of error codes.
    
        It is recommended to use [reverse-DNS naming](https://en.wikipedia.org/wiki/Reverse_domain_name_notation)
        to avoid name conflicts.
    **/
    static var domain: String { get }

    /**
        An integer representing the specific error. This need not necessarily
        be the `rawValue` of an enumeration; an enumeration with associated
        types can instead define its own error codes.
    **/
    var code: ErrorCode { get }
    
    /// A domain-specific diagnostic describing the nature of the error.
    var failureReason: String { get }
    
    /**
        As inherited from `Printable`.

        To not include the localized description, return an empty string.
        (The user deserves better, though.)

        :returns: A localized, user-friendly description of the error.
    **/
    var description: String { get }
}

/**
    Create an instance of an error using the given `ErrorRepresentable` type.

    :param: code A variable of error-representable type
    :param: underlying An optional error the resulting error will wrap

    :returns: An initialized error object
**/
public func error<T: ErrorRepresentable>(#code: T, underlying: NSError? = nil) -> NSError {
    var userInfo = [NSObject: AnyObject]()

    let description = code.description
    if !description.isEmpty {
        userInfo[NSLocalizedDescriptionKey] = description
    }

    let reason = code.failureReason
    if !reason.isEmpty {
        userInfo[NSLocalizedFailureReasonErrorKey] = reason
    }

    if let underlying = underlying {
        userInfo[NSUnderlyingErrorKey] = underlying
    }

    return NSError(domain: T.domain, code: numericCast(code.code), userInfo: userInfo)
}

/// Key for the `__FILE__` constant in generated errors
public let ErrorFileKey = "errorFile"

/// Key for the `__LINE__` constant in generated errors
public let ErrorLineKey = "errorLine"

/// Generate an automatic domainless `NSError`.
public func error(_ message: String? = nil, file: StaticString = __FILE__, line: UWord = __LINE__) -> NSError {
    var userInfo: [String: AnyObject] = [
        ErrorFileKey: "\(file)",
        ErrorLineKey: line
    ]
    
    if let message = message where !message.isEmpty {
        userInfo[NSLocalizedDescriptionKey] = message
    }
    
    return NSError(domain: "", code: -1, userInfo: userInfo)
}

func identityError(error: NSError) -> NSError {
    return error
}
