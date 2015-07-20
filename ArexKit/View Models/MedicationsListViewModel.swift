import ReactiveCocoa

public class MedicationsListViewModel {
    public let medicationsUpdated: Signal<Void, NoError>

    public var cellViewModels: LazyRandomAccessCollection<MapCollection<[Medication], MedicationListCellViewModel>> {
        return lazy(medications).map({ MedicationListCellViewModel(medication: $0) })
    }

    public var detailViewModels: LazyRandomAccessCollection<MapCollection<[Medication], MedicationDetailViewModel>> {
        return lazy(medications).map({ [unowned self] in
            MedicationDetailViewModel(medicationsController: self.medicationsController, medication: $0)
        })
    }

    private let medicationsController: MedicationsController
    private var medications = [Medication]()
    private let medicationsDisposable = SerialDisposable()

    public init(medicationsController: MedicationsController) {
        self.medicationsController = medicationsController

        // Prepare for observation.
        let (signal, observer) = Signal<Void, NoError>.pipe()

        // Assign the signal to the public property.
        // This signal will forward events received below.
        self.medicationsUpdated = signal

        // Start the observation.
        // We snatch the Medication values from the signal and map to void.
        // This prevents leaking the Medication instances.
        self.medicationsDisposable.innerDisposable = self.medicationsController.medications()
            .flatMapError(catchAll)
            .on(next: { [unowned self] in self.medications = $0 })
            .map(void)
            .start(observer)
    }

    deinit {
        medicationsDisposable.dispose()
    }

    public var isEmpty: Bool {
        return medications.isEmpty
    }
    
    public var count: Int {
        return medications.count
    }

    public func newDetailViewModel() -> MedicationDetailViewModel {
        return MedicationDetailViewModel(medicationsController: medicationsController, medication: Medication())
    }

    public func deleteViewModel(atIndex index: Int) -> SignalProducer<Void, MedicationsControllerError> {
        return medicationsController.delete(medication: &medications[index])
    }
}
