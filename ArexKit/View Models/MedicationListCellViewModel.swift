import Pistachio

public class MedicationListCellViewModel {
    private let medication: Medication

    public init(medication: Medication) {
        self.medication = medication
    }

    public var text: String? {
        return get(MedicationLenses.name, medication)
    }

    public var detailText: String? {
        return get(MedicationLenses.strength, medication)
    }
}
