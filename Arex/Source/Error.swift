//
//  Error.swift
//  Arex
//
//  Created by Alexsander Akers on 2/10/15.
//  Copyright (c) 2015 Pandamonia. All rights reserved.
//

import Foundation

enum Error: Int {
    static let Domain = "ArexError"

    case Unknown
    case SavedDataInitializationFailure
    case SaveFailure

    var localizedDescription: String {
        switch self {
        case .Unknown:
            return NSLocalizedString("An unknown error occurred.", comment: "")
        case .SavedDataInitializationFailure:
            return NSLocalizedString("Failed to initialize the application's saved data", comment: "")
        case .SaveFailure:
            return NSLocalizedString("Failed to save data.", comment: "")
        }
    }

    var localizedFailureReason: String? {
        switch self {
        case .Unknown:
            return nil
        case .SavedDataInitializationFailure:
            return NSLocalizedString("There was an error creating or loading the application's saved data.", comment: "")
        case .SaveFailure:
            return NSLocalizedString("There was an error saving data.", comment: "")
        }
    }

    func toError(underlyingError: NSError? = nil) -> NSError {
        var userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: localizedDescription]
        if let localizedFailureReason = localizedFailureReason {
            userInfo[NSLocalizedFailureReasonErrorKey] = localizedFailureReason
        }
        if let underlyingError = underlyingError {
            userInfo[NSUnderlyingErrorKey] = underlyingError
        }

        return NSError(domain: Error.Domain, code: rawValue, userInfo: userInfo)
    }
}
