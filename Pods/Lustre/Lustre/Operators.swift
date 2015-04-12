//
//  Operators.swift
//  Lustre
//
//  Created by Zachary Waldowski on 3/29/15.
//  Copyright (c) 2015 Zachary Waldowski. All rights reserved.
//

import Foundation

/// Haskell-like operator for `flatMap`, with chaining working at a higher
/// precedence than function application.
infix operator >>== {
    associativity left
    precedence 150
}

public func >>==<IR: ResultType, RR: ResultType>(result: IR, @noescape transform: IR.Value -> RR) -> RR {
    return result.flatMap(transform)
}
