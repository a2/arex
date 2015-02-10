//
//  Schedule.swift
//  Arex
//
//  Created by Alexsander Akers on 2/10/15.
//  Copyright (c) 2015 Pandamonia. All rights reserved.
//

import CoreData
import Foundation

class Schedule: NSManagedObject {
    // MARK: - Attributes

    @NSManaged var on: NSNumber?
    var onValue: Bool? {
        get {
            return on?.boolValue
        }
        set {
            on = newValue.map { NSNumber(bool: $0) }
        }
    }

    // MARK: - Relationships

    @NSManaged var medication: Medication?
}
