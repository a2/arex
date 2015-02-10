//
//  OneOffSchedule.swift
//  Arex
//
//  Created by Alexsander Akers on 2/10/15.
//  Copyright (c) 2015 Pandamonia. All rights reserved.
//

import CoreData
import Foundation

class OneOffSchedule: Schedule {
    // MARK: - Attributes

    @NSManaged var fireDate: NSDate?
    @NSManaged var timeZone: NSTimeZone?
}
