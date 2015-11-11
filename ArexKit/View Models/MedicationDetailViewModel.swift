import Monocle
import Pistachio
import ReactiveCocoa

public class MedicationDetailViewModel {
    private var medication: Medication
    private let medicationsController: MedicationsController
    public let form: MedicationDetailForm

    public init(medicationsController: MedicationsController, medication: Medication) {
        self.medication = medication
        self.medicationsController = medicationsController
        self.form = MedicationDetailForm(medication: medication)

        self.isNew = !get(MedicationLenses.isPersisted, medication)

        let name = DynamicProperty(object: self.form, keyPath: "name")
        self.name = name.map { $0 as? String }

        // If `medication` is new, start in editing mode.
        self.canSave = self.name.map { name in
            return name.map { !$0.isEmpty } ?? false
        }
    }

    // MARK: Properties

    public let isNew: Bool
    public let canSave: AnyProperty<Bool>
    public let name: AnyProperty<String?>

    public var isPersisted: Bool {
        return get(MedicationLenses.isPersisted, medication)
    }

    // MARK: Actions

    public var saveChanges: Action<Void, Void, MedicationsControllerError> {
        return Action(enabledIf: self.canSave) { [unowned self] _ in
            var medication = self.form.medication
            return self.medicationsController.save(medication: &medication)
                .map { return undefined("Did not expect MedicationsController.save(_:) to send a next event") }
                .concat(SignalProducer { observer, disposable in disposable += SignalProducer(value: medication).start(observer) })
                .map(void)
        }
    }
}

// MARK: - Lenses

private struct MedicationDetailViewModelLenses {
    static let medication = Lens(
        get: { $0.medication },
        set: { (inout viewModel: MedicationDetailViewModel, medication) in viewModel.medication = medication }
    )
}
