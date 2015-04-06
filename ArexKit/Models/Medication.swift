import AddressBook
import Pistachio

public struct Medication {
    private var doctorRecordID: ABRecordID?
    private var dosesLeft: Int?
    private var lastFilledDate: NSDate?
    private var name: String?
    private var note: String?
    private var pharmacyRecordID: ABRecordID?
    private var pictureData: NSData?
    private var schedule: Schedule?
    private var strength: String?
    private var times: [Time]
    private var uuid: NSUUID?

    public init(doctorRecordID: ABRecordID? = nil, dosesLeft: Int? = nil, lastFilledDate: NSDate? = nil, name: String? = nil, note: String? = nil, pharmacyRecordID: ABRecordID? = nil, pictureData: NSData? = nil, schedule: Schedule? = nil, strength: String? = nil, times: [Time] = [], uuid: NSUUID? = nil) {
        self.doctorRecordID = doctorRecordID
        self.dosesLeft = dosesLeft
        self.lastFilledDate = lastFilledDate
        self.name = name
        self.note = note
        self.pharmacyRecordID = pharmacyRecordID
        self.pictureData = pictureData
        self.schedule = schedule
        self.strength = strength
        self.times = times
        self.uuid = uuid
    }
}

public struct MedicationLenses {
    public static let doctorRecordID = Lens(
        get: { $0.doctorRecordID },
        set: { (inout medication: Medication, recordID) in medication.doctorRecordID = flush(recordID, kABRecordInvalidID) }
    )

    public static let dosesLeft = Lens(
        get: { $0.dosesLeft },
        set: { (inout medication: Medication, dosesLeft) in medication.dosesLeft = dosesLeft }
    )

    public static let lastFilledDate = Lens(
        get: { $0.lastFilledDate },
        set: { (inout medication: Medication, lastFilledDate) in medication.lastFilledDate = lastFilledDate }
    )

    public static let name = Lens(
        get: { $0.name },
        set: { (inout medication: Medication, name) in medication.name = flush(name, not(isEmpty)) }
    )

    public static let note = Lens(
        get: { $0.note },
        set: { (inout medication: Medication, note) in medication.note = flush(note, not(isEmpty)) }
    )

    public static let pharmacyRecordID = Lens(
        get: { $0.pharmacyRecordID },
        set: { (inout medication: Medication, recordID) in medication.pharmacyRecordID = flush(recordID, kABRecordInvalidID) }
    )

    public static let pictureData = Lens(
        get: { $0.pictureData },
        set: { (inout medication: Medication, pictureData) in medication.pictureData = pictureData }
    )

    public static let schedule = Lens(
        get: { $0.schedule },
        set: { (inout medication: Medication, schedule) in medication.schedule = schedule }
    )

    public static let strength = Lens(
        get: { $0.strength },
        set: { (inout medication: Medication, strength) in medication.strength = flush(strength, not(isEmpty)) }
    )

    public static let times = Lens(
        get: { $0.times },
        set: { (inout medication: Medication, times) in medication.times = times }
    )

    public static let uuid = Lens(
        get: { $0.uuid },
        set: { (inout medication: Medication, uuid) in medication.uuid = uuid }
    )
}
