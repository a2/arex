public class TodayViewModel {
    private let medicationsController: MedicationsController

    public init(medicationsController: MedicationsController) {
        self.medicationsController = medicationsController
    }

    public func medicationsListViewModel() -> MedicationsListViewModel {
        return MedicationsListViewModel(medicationsController: medicationsController)
    }
}
