import AddressBook
import Pistachio
import UIKit

struct Medication {
    var doctorRecordID: ABRecordID?
    var dosesLeft: Int?
    var lastFilledDate: NSDate?
    var name: String?
    var note: String?
    var pharmacyRecordID: ABRecordID?
    var pictureData: NSData?
    var schedules: [Schedule]
    var strength: String?

    init(doctorRecordID: ABRecordID? = nil, dosesLeft: Int? = nil, lastFilledDate: NSDate? = nil, name: String? = nil, note: String? = nil, pharmacyRecordID: ABRecordID? = nil, pictureData: NSData? = nil, schedules: [Schedule] = [], strength: String? = nil) {
        self.doctorRecordID = doctorRecordID
        self.dosesLeft = dosesLeft
        self.lastFilledDate = lastFilledDate
        self.name = name
        self.note = note
        self.pharmacyRecordID = pharmacyRecordID
        self.pictureData = pictureData
        self.schedules = schedules
        self.strength = strength
    }
}

struct MedicationLenses {
    static let doctorRecordID = Lens(
        get: { $0.doctorRecordID },
        set: { (inout medication: Medication, recordID) in medication.doctorRecordID = flush(recordID, kABRecordInvalidID) }
    )

    static let dosesLeft = Lens(
        get: { $0.dosesLeft },
        set: { (inout medication: Medication, dosesLeft) in medication.dosesLeft = dosesLeft }
    )

    static let lastFilledDate = Lens(
        get: { $0.lastFilledDate },
        set: { (inout medication: Medication, lastFilledDate) in medication.lastFilledDate = lastFilledDate }
    )

    static let name = Lens(
        get: { $0.name },
        set: { (inout medication: Medication, name) in medication.name = name }
    )

    static let note = Lens(
        get: { $0.note },
        set: { (inout medication: Medication, note) in medication.note = note }
    )

    static let pharmacyRecordID = Lens(
        get: { $0.pharmacyRecordID },
        set: { (inout medication: Medication, recordID) in medication.pharmacyRecordID = flush(recordID, kABRecordInvalidID) }
    )

    static let pictureData = Lens(
        get: { $0.pictureData },
        set: { (inout medication: Medication, pictureData) in medication.pictureData = pictureData }
    )

    static let schedules = Lens(
        get: { $0.schedules },
        set: { (inout medication: Medication, schedules) in medication.schedules = schedules }
    )

    static let strength = Lens(
        get: { $0.strength },
        set: { (inout medication: Medication, strength) in medication.strength = strength }
    )
}
