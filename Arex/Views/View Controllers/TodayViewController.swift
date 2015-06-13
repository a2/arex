import ArexKit
import UIKit

class TodayViewController: UITableViewController {
    private struct Constants {
        enum SegueIdentifier: String {
            case ShowMedicationsList = "ShowMedicationsList"
        }
    }

    var viewModel = TodayViewModel(medicationsController: MedicationsController())

    // MARK: - View Controller


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        func segueIdentifier(segue: UIStoryboardSegue) -> Constants.SegueIdentifier? {
            return segue.identifier.flatMap { Constants.SegueIdentifier(rawValue: $0) }
        }

        if let identifier = segueIdentifier(segue) {
            switch identifier {
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
