import AddressBook
import Monocle
import Pistachio

public struct Medication {
    private var name: String?
    private var schedule: Schedule
    private var strength: String?
    private var times: [Time]
    private var uuid: NSUUID?

    public init(name: String? = nil, schedule: Schedule = .NotCurrentlyTaken, strength: String? = nil, times: [Time] = [], uuid: NSUUID? = nil) {
        self.name = name
        self.schedule = schedule
        self.strength = strength
        self.times = times
        self.uuid = uuid
    }
}

extension Medication: CustomStringConvertible {
    public var description: String {
        let nameDescription = name.map { "\"" + $0 + "\"" } ?? "nil"
        let strengthDescription = strength.map { "\"" + $0 + "\"" } ?? "nil"
        let timesDescription = "[" + ", ".join(times.map { String($0) }) + "]"
        let uuidDescription = uuid.map { $0.UUIDString } ?? "nil"
        return "Medication(name: \(nameDescription), schedule: \(String(schedule)), strength: \(strengthDescription), times: \(timesDescription), uuid: \(uuidDescription))"
    }
}

public struct MedicationLenses {
    public static let name = Lens(
        get: { $0.name },
        set: { (inout medication: Medication, name) in
            if let name = name where !name.isEmpty {
                medication.name = name
            } else {
                medication.name = nil
            }
        }
    )

    public static let schedule = Lens(
        get: { $0.schedule },
        set: { (inout medication: Medication, schedule) in medication.schedule = schedule }
    )

    public static let strength = Lens(
        get: { $0.strength },
        set: { (inout medication: Medication, strength) in
            if let strength = strength where !strength.isEmpty {
                medication.strength = strength
            } else {
                medication.strength = nil
            }
        }
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
