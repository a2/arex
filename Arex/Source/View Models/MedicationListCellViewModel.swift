import Pistachio

class MedicationListCellViewModel: ViewModel {
    private let medication: Medication

    init(medication: Medication) {
        self.medication = medication
    }

    var text: String? {
        return get(MedicationLenses.name, medication)
    }

    var detailText: String? {
        return get(MedicationLenses.strength, medication)
    }
}
