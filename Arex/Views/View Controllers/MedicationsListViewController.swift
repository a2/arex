import ArexKit
import ReactiveCocoa
import UIKit

class MedicationsListViewController: UITableViewController {
    private struct Constants {
        enum CellIdentifiers: String {
            case MedicationCell = "MedicationCell"
        }

        enum SegueIdentifier: String {
            case DismissMedications = "DismissMedications"
            case ShowMedicationDetail = "ShowMedicationDetail"
        }
    }

    var viewModel: MedicationsListViewModel!

    private let disposable = CompositeDisposable()

    deinit {
        disposable.dispose()
    }

    // MARK: - Actions

    @IBAction func newMedication(sender: AnyObject?) {
        let senderViewModel = viewModel.newDetailViewModel()
        performSegueWithIdentifier(Constants.SegueIdentifier.ShowMedicationDetail.rawValue, sender: senderViewModel)
    }

    @IBAction func dismiss(sender: AnyObject?) {
        performSegueWithIdentifier(Constants.SegueIdentifier.DismissMedications.rawValue, sender: sender)
    }

    @IBAction func dismissMedicationDetail(segue: UIStoryboardSegue) {

    }

    // MARK: - Configuration

    func configureNavigationItem() {
        navigationItem.rightBarButtonItem = editButtonItem()
        updateNavigationItem(editing, false)
    }

    func updateNavigationItem(editing: Bool, _ animated: Bool) {
        let leftBarButtonItem: UIBarButtonItem?
        if editing {
            leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newMedication:")
        } else {
            leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss:")
        }

        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: animated)
    }

    // MARK: - View Life Cycle

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        updateNavigationItem(editing, animated)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        func segueIdentifier(segue: UIStoryboardSegue) -> Constants.SegueIdentifier? {
            return segue.identifier.flatMap { Constants.SegueIdentifier(rawValue: $0) }
        }

        if let identifier = segueIdentifier(segue) {
            switch identifier {
            case .DismissMedications:
                break
            case .ShowMedicationDetail:
                let navigationController = segue.destinationViewController as! UINavigationController
                let medicationDetailViewController = navigationController.viewControllers[0] as! MedicationDetailViewController
                medicationDetailViewController.viewModel = sender as! MedicationDetailViewModel
            }
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItem()

        disposable += viewModel.medicationsUpdated.observe(next: { [weak self] in
            self?.tableView.reloadData()
        })
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.MedicationCell.rawValue, forIndexPath: indexPath) as? MedicationsListCell
            ?? undefined("Unexpected cell class for reuse identifier \(Constants.CellIdentifiers.MedicationCell)")
        cell.configure(viewModel: viewModel.cellViewModels[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let senderViewModel = viewModel.detailViewModels[indexPath.row]
        performSegueWithIdentifier(Constants.SegueIdentifier.ShowMedicationDetail.rawValue, sender: senderViewModel)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        precondition(editingStyle == .Delete)

        viewModel.deleteViewModel(atIndex: indexPath.row)
            |> start({ error in
                // Handle error
            }, completed: {

            })
    }
}
