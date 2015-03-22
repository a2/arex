import AddressBook
import Pistachio

struct Medication: Hashable {
    private var doctorRecordID: ABRecordID?
    private var dosesLeft: Int?
    private var lastFilledDate: NSDate?
    private var name: String?
    private var note: String?
    private var pharmacyRecordID: ABRecordID?
    private var pictureData: NSData?
    private var schedules: [Schedule]
    private var strength: String?
    private var uuid: NSUUID?

    init(doctorRecordID: ABRecordID? = nil, dosesLeft: Int? = nil, lastFilledDate: NSDate? = nil, name: String? = nil, note: String? = nil, pharmacyRecordID: ABRecordID? = nil, pictureData: NSData? = nil, schedules: [Schedule] = [], strength: String? = nil, uuid: NSUUID? = nil) {
        self.doctorRecordID = doctorRecordID
        self.dosesLeft = dosesLeft
        self.lastFilledDate = lastFilledDate
        self.name = name
        self.note = note
        self.pharmacyRecordID = pharmacyRecordID
        self.pictureData = pictureData
        self.schedules = schedules
        self.strength = strength
        self.uuid = uuid
    }

    var hashValue: Int {
        if let uuid = uuid {
            return uuid.hash
        } else {
            return (name?.hash ?? 0) ^ (strength?.hash ?? 0)
        }
    }
}

func ==(lhs: Medication, rhs: Medication) -> Bool {
    switch (lhs.uuid, rhs.uuid) {
    case let (.Some(lhu), .Some(rhu)):
        return lhu == rhu
    default:
        return lhs.name == rhs.name && lhs.strength ==  rhs.strength
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
        set: { (inout medication: Medication, name) in medication.name = flush(name, not(isEmpty)) }
    )

    static let note = Lens(
        get: { $0.note },
        set: { (inout medication: Medication, note) in medication.note = flush(note, not(isEmpty)) }
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
        set: { (inout medication: Medication, strength) in medication.strength = flush(strength, not(isEmpty)) }
    )

    static let uuid = Lens(
        get: { $0.uuid },
        set: { (inout medication: Medication, uuid) in medication.uuid = uuid }
    )
}
