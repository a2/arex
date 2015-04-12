//
//  Error.swift
//  Lustre
//
//  Created by Zachary Waldowski on 12/10/14.
//  Copyright (c) 2014-2015. All rights reserved.
//

import Foundation

public protocol ErrorRepresentable: Printable {
    typealias ErrorCode: SignedIntegerType

    static var domain: String { get }
    var code: ErrorCode { get }
    var failureReason: String { get }
}

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

/// Key for the __FILE__ constant in generated errors
public let ErrorFileKey = "errorFile"

/// Key for the __LINE__ constant in generated errors
public let ErrorLineKey = "errorLine"

/// Generate an automatic domainless `NSError`.
public func error(_ message: String? = nil, file: StaticString = __FILE__, line: UWord = __LINE__) -> NSError {
    var userInfo: [String: AnyObject] = [
        ErrorFileKey: "\(file)",
        ErrorLineKey: line
    ]
    
    if let message = message {
        userInfo[NSLocalizedDescriptionKey] = message
    }
    
    return NSError(domain: "", code: -1, userInfo: userInfo)
}

func identityError(error: NSError) -> NSError {
    return error
}
