import ReactiveCocoa

class MedicationsListViewModel: ViewModel {
    let medicationsUpdated: Signal<Void, NoError>

    var cellViewModels: LazyRandomAccessCollection<MapCollectionView<[Medication], MedicationListCellViewModel>> {
        return lazy(medications).map({ MedicationListCellViewModel(medication: $0) })
    }

    var detailViewModels: LazyRandomAccessCollection<MapCollectionView<[Medication], MedicationDetailViewModel>> {
        return lazy(medications).map({ [unowned self] in
            MedicationDetailViewModel(medicationsController: self.medicationsController, medication: $0)
        })
    }

    private let medicationsController: MedicationsController
    private var medications = [Medication]()
    private let medicationsUpdatedObserver: SinkOf<Event<Void, NoError>>
    private let disposable = SerialDisposable()

    init(medicationsController: MedicationsController) {
        self.medicationsController = medicationsController
        (self.medicationsUpdated, self.medicationsUpdatedObserver) = Signal.pipe()

        super.init()

        self.disposable.innerDisposable = self.medicationsController.medications()
            |> forwardWhileActive
            |> catch(catchAll)
            |> on(
                // TODO: Remove the `gobble`s when Swift doesn't segfault.
                started: void,
                event: void,
                next: { [unowned self] in self.medications = $0 },
                error: void,
                completed: void,
                interrupted: void,
                terminated: void,
                disposed: void
            )
            |> map(void)
            |> start(self.medicationsUpdatedObserver)
    }

    var isEmpty: Bool {
        return medications.isEmpty
    }
    
    var count: Int {
        return medications.count
    }

    func newDetailViewModel() -> MedicationDetailViewModel {
        return MedicationDetailViewModel(medicationsController: medicationsController, medication: Medication())
    }
}
