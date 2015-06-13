import Monocle
import Pistachio

public struct Medication {
    private var isPersisted = false
    private var name: String?
    private var schedule: Schedule
    private var strength: String?
    private var times: [Time]
    private var UUID: NSUUID

    public init(name: String? = nil, schedule: Schedule = .NotCurrentlyTaken, strength: String? = nil, times: [Time] = [], UUID: NSUUID? = nil) {
        self.UUID = UUID ?? NSUUID()
        self.isPersisted = UUID != nil

        self.name = name
        self.schedule = schedule
        self.strength = strength
        self.times = times
    }
}

// MARK: - CustomStringConvertible

extension Medication: CustomStringConvertible {
    public var description: String {
        let nameDescription = name.map { "\"" + $0 + "\"" } ?? "nil"
        let strengthDescription = strength.map { "\"" + $0 + "\"" } ?? "nil"
        let timesDescription = "[" + ", ".join(times.map { String($0) }) + "]"
        return "Medication(name: \(nameDescription), schedule: \(String(schedule)), strength: \(strengthDescription), times: \(timesDescription), UUID: \(UUID.UUIDString))"
    }
}

// MARK: - Equatable

extension Medication: Equatable {}

public func ==(lhs: Medication, rhs: Medication) -> Bool {
    return lhs.UUID == rhs.UUID
}

// MARK: - Hashable

extension Medication: Hashable {
    public var hashValue: Int {
        return UUID.hashValue
    }
}

// MARK: - Lenses

public struct MedicationLenses {
    public static let isPersisted = Lens(
        get: { $0.isPersisted },
        set: { (inout medication: Medication, isPersisted) in medication.isPersisted = isPersisted }
    )

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

    public static let UUID = Lens(
        get: { $0.UUID },
        set: { (medication: Medication, _) in undefined("Cannot set UUID with MedicationLenses.UUID") }
    )
}
