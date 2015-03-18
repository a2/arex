import ReactiveCocoa

class MedicationsListViewModel: ViewModel {
    let medicationsUpdated: Signal<Void, NoError>
    private(set) var medications = [Medication]()

    private let medicationsUpdatedObserver: SinkOf<Event<Void, NoError>>

    private let medicationsController: MedicationsController
    private let disposable = CompositeDisposable()

    init(medicationsController: MedicationsController) {
        self.medicationsController = medicationsController
        (self.medicationsUpdated, self.medicationsUpdatedObserver) = Signal.pipe()

        super.init()

        let disposable = self.medicationsController.medications()
            |> forwardWhileActive
            |> catch(catchAll)
            |> on(
                // TODO: Remove the `gobble`s when Swift doesn't segfault.
                started: gobble,
                event: gobble,
                next: { [unowned self] in self.medications = $0 },
                error: gobble,
                completed: gobble,
                interrupted: gobble,
                terminated: gobble,
                disposed: gobble
            )
            |> map(gobble)
            |> start(medicationsUpdatedObserver)
        self.disposable.addDisposable(disposable)
    }

    var count: Int {
        return medications.count
    }
}
