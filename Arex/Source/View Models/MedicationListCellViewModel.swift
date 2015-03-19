class MedicationListCellViewModel: ViewModel {
    private let medication: Medication

    init(medication: Medication) {
        self.medication = medication
    }

    var text: String? {
        return medication.name
    }

    var detailText: String? {
        return medication.strength
    }
}
