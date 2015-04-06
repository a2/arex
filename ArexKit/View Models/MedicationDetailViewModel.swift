public class MedicationDetailViewModel {
    private let medication: Medication
    private let medicationsController: MedicationsController

    public init(medicationsController: MedicationsController, medication: Medication) {
        self.medication = medication
        self.medicationsController = medicationsController
    }

    public lazy var infoViewModel: MedicationDetailInfoViewModel = {
        return MedicationDetailInfoViewModel(medicationsController: self.medicationsController, medication: self.medication)
    }()
}
