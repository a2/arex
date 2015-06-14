import ArexKit
import UIKit

class TodayViewController: UITableViewController {
    var viewModel = TodayViewModel(medicationsController: MedicationsController())

    // MARK: - View Controller


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        func segueValue(segue: UIStoryboardSegue) -> Segue? {
            return segue.identifier.flatMap { Segue(rawValue: $0) }
        }

        if let segueValue = segueValue(segue) {
            switch segueValue {
            case .ShowMedicationsList:
                let navigation = segue.destinationViewController as! UINavigationController
                let list = navigation.viewControllers[0] as! MedicationsListViewController
                list.viewModel = viewModel.medicationsListViewModel()
            }
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }

    // MARK: - Actions

    @IBAction func dismissMedications(segue: UIStoryboardSegue) {
        
    }
}
