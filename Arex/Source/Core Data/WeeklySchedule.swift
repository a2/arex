//
//  WeeklySchedule.swift
//  Arex
//
//  Created by Alexsander Akers on 2/10/15.
//  Copyright (c) 2015 Pandamonia. All rights reserved.
//

import CoreData
import Foundation

class WeeklySchedule: Schedule {
    // MARK: - Attributes

    @NSManaged var daysOfWeek: NSNumber?
    var daysOfWeekValue: Int16? {
        get {
            return daysOfWeek?.shortValue
        }
        set {
            daysOfWeek = newValue.map { NSNumber(short: $0) }
        }
    }

    @NSManaged var hour: NSNumber?
    var hourValue: Int16? {
        get {
            return hour?.shortValue
        }
        set {
            hour = newValue.map { NSNumber(short: $0) }
        }
    }

    @NSManaged var minute: NSNumber?
    var minuteValue: Int16? {
        get {
            return minute?.shortValue
        }
        set {
            minute = newValue.map { NSNumber(short: $0) }
        }
    }
}
