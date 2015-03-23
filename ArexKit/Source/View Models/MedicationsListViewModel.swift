import ReactiveCocoa

public class MedicationsListViewModel: ViewModel {
    public let medicationsUpdated: Signal<Void, NoError>

    public var cellViewModels: LazyRandomAccessCollection<MapCollectionView<[Medication], MedicationListCellViewModel>> {
        return lazy(medications).map({ MedicationListCellViewModel(medication: $0) })
    }

    public var detailViewModels: LazyRandomAccessCollection<MapCollectionView<[Medication], MedicationDetailViewModel>> {
        return lazy(medications).map({ [unowned self] in
            MedicationDetailViewModel(medicationsController: self.medicationsController, medication: $0)
        })
    }

    private let medicationsController: MedicationsController
    private var medications = [Medication]()
    private let medicationsUpdatedObserver: SinkOf<Event<Void, NoError>>
    private let disposable = SerialDisposable()

    public init(medicationsController: MedicationsController) {
        self.medicationsController = medicationsController
        (self.medicationsUpdated, self.medicationsUpdatedObserver) = Signal.pipe()

        super.init()

        self.disposable.innerDisposable = self.medicationsController.medications()
            |> forwardWhileActive
            |> catch(catchAll)
            |> on(next: { [unowned self] in self.medications = $0 })
            |> map(void)
            |> start(self.medicationsUpdatedObserver)
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
}
