//
//  Medication.swift
//  Arex
//
//  Created by Alexsander Akers on 2/10/15.
//  Copyright (c) 2015 Pandamonia. All rights reserved.
//

import AddressBook
import CoreData
import Foundation
import UIKit

class Medication: NSManagedObject {
    // MARK: - Attributes

    @NSManaged var doctorRecordID: NSNumber?
    var doctorRecordIDValue: ABRecordID? {
        get {
            return doctorRecordID?.intValue
        }
        set {
            doctorRecordID = newValue.map { NSNumber(int: $0) }
        }
    }

    @NSManaged var dosesLeft: NSNumber?
    var dosesLeftValue: Int16? {
        get {
            return dosesLeft?.shortValue
        }
        set {
            dosesLeft = newValue.map { NSNumber(short: $0) }
        }
    }

    @NSManaged var lastFilledDate: NSDate?

    @NSManaged var name: String?

    @NSManaged var note: String?

    @NSManaged var pharmacyRecordID: NSNumber?
    var pharmacyRecordIDValue: ABRecordID? {
        get {
            return pharmacyRecordID?.intValue
        }
        set {
            pharmacyRecordID = newValue.map { NSNumber(int: $0) }
        }
    }

    @NSManaged var pictureData: NSData?
    var picture: UIImage? {
        get {
            return pictureData.map { UIImage(data: $0) } ?? nil
        }
        set {
            pictureData = newValue.map { UIImageJPEGRepresentation($0, 0.7) }
        }
    }

    @NSManaged var strength: String?

    // MARK: - Relationships

    @NSManaged var schedules: NSOrderedSet
}
