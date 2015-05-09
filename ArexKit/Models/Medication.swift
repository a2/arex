import AddressBook
import Monocle
import Pistachio

public struct Medication: Printable {
    private var name: String?
    private var pictureData: NSData?
    private var schedule: Schedule?
    private var strength: String?
    private var times: [Time]
    private var uuid: NSUUID?

    public init(name: String? = nil, pictureData: NSData? = nil, schedule: Schedule? = nil, strength: String? = nil, times: [Time] = [], uuid: NSUUID? = nil) {
        self.name = name
        self.pictureData = pictureData
        self.schedule = schedule
        self.strength = strength
        self.times = times
        self.uuid = uuid
    }

    public var description: String {
        let nameDescription = name.map { "\"" + $0 + "\"" } ?? "nil"
        let pictureDataDescription = pictureData.map { "<\($0.length) byte(s)>" } ?? "nil"
        let scheduleDescription = schedule.map(toString) ?? "nil"
        let strengthDescription = strength.map { "\"" + $0 + "\"" } ?? "nil"
        let timesDescription = "[" + ", ".join(times.map(toString)) + "]"
        let uuidDescription = uuid.map { $0.UUIDString } ?? "nil"
        return "Medication(name: \(nameDescription), pictureData: \(pictureDataDescription), schedule: \(scheduleDescription), strength: \(strengthDescription), times: \(timesDescription), uuid: \(uuidDescription))"
    }
}

public struct MedicationLenses {
    public static let name = Lens(
        get: { $0.name },
        set: { (inout medication: Medication, name) in medication.name = flush(name, not(isEmpty)) }
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
