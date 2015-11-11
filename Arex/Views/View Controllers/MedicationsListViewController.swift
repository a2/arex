import ArexKit
import ReactiveCocoa
import UIKit

class MedicationsListViewController: UITableViewController {
    var viewModel: MedicationsListViewModel!

    private let disposable = CompositeDisposable()

    deinit {
        disposable.dispose()
    }

    // MARK: - Actions

    @IBAction func newMedication(sender: AnyObject?) {
        let senderViewModel = viewModel.newDetailViewModel()
        performSegue(Segue.ShowMedicationDetail, sender: senderViewModel)
    }

    @IBAction func dismiss(sender: AnyObject?) {
        performSegue(Segue.DismissMedications, sender: sender)
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
        func segueValue(segue: UIStoryboardSegue) -> Segue? {
            return segue.identifier.flatMap { Segue(rawValue: $0) }
        }

        if let segueValue = segueValue(segue) {
            switch segueValue {
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

        let observer = Observer<(), NoError>(next: { [weak self] () -> () in self?.tableView.reloadData() })
        disposable += viewModel.medicationsUpdated.observe(observer)
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(Reusable.MedicationCell, forIndexPath: indexPath) as? MedicationsListCell
            ?? undefined("Unexpected cell class for reuse identifier \(Reusable.MedicationCell)")
        cell.configure(viewModel: viewModel.cellViewModels[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let senderViewModel = viewModel.detailViewModels[indexPath.row]
        performSegue(Segue.ShowMedicationDetail, sender: senderViewModel)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        precondition(editingStyle == .Delete)

        let observer = Observer<Void, MedicationsControllerError>(failed: { error in
            // Handle error
        }, completed: {

        })
        viewModel.deleteViewModel(atIndex: indexPath.row)
            .start(observer)
    }
}
