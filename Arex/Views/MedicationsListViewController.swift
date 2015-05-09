import ArexKit
import ReactiveCocoa
import UIKit

class MedicationsListViewController: UITableViewController {
    private struct Constants {
        struct CellIdentifiers {
            static let MedicationCell = "MedicationCell"
        }

        struct SegueIdentifiers {
            static let NewMedication = "NewMedication"
            static let ShowMedication = "ShowMedication"
        }
    }

    private let viewModel = MedicationsListViewModel(medicationsController: MedicationsController())

    private let disposable = CompositeDisposable()

    deinit {
        disposable.dispose()
    }

    // MARK: - Actions

    @IBAction func dismissModalEditor(segue: UIStoryboardSegue) {

    }

    // MARK: - View Life Cycle

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        func configureDestinationViewController(destinationViewController: AnyObject, viewModel: MedicationDetailViewModel) {
            let navigationController = destinationViewController as! UINavigationController
            let medicationDetailViewController = navigationController.viewControllers[0] as! MedicationDetailViewController
            medicationDetailViewController.viewModel = viewModel
        }

        switch segue.identifier {
        case .Some(Constants.SegueIdentifiers.NewMedication):
            configureDestinationViewController(segue.destinationViewController, viewModel.newDetailViewModel())
        case .Some(Constants.SegueIdentifiers.ShowMedication):
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let detailViewModel = viewModel.detailViewModels[indexPath.row]
            configureDestinationViewController(segue.destinationViewController, detailViewModel)
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        disposable += viewModel.medicationsUpdated.observe(next: { [weak self] in
            self?.tableView.reloadData()
        })
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.MedicationCell, forIndexPath: indexPath) as! MedicationsListCell
        cell.configure(viewModel: viewModel.cellViewModels[indexPath.row])
        cell.layoutIfNeeded()
        return cell
    }
}
