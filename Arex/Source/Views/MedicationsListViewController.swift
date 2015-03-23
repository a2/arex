import UIKit

class MedicationsListViewController: UITableViewController {
    private struct Constants {
        struct CellIdentifiers {
            static let MedicationCell = "MedicationCell"
        }

        struct SegueIdentifiers {
            static let AddMedication = "AddMedication"
            static let EditMedication = "EditMedication"
        }
    }

    private let viewModel = MedicationsListViewModel(medicationsController: MedicationsController())

    // MARK: - Actions

    @IBAction func dismissModalEditor(segue: UIStoryboardSegue) {

    }

    // MARK: - View Life Cycle

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case .Some(Constants.SegueIdentifiers.AddMedication):
            if let navigation = segue.destinationViewController as? UINavigationController,
                detail = navigation.viewControllers.first as? MedicationDetailViewController {
                detail.viewModel = viewModel.newDetailViewModel()
            }
        case .Some(Constants.SegueIdentifiers.EditMedication):
            if let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell),
                detail = segue.destinationViewController as? MedicationDetailViewController {
                detail.viewModel = viewModel.detailViewModels[indexPath.row]
            }
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.MedicationCell, forIndexPath: indexPath) as! MedicationsListCell
        cell.configure(viewModel: viewModel.cellViewModels[indexPath.row])
        return cell
    }
}
