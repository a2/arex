import ArexKit
import ReactiveCocoa
import UIKit

class MedicationDetailViewController: FXFormViewController, MedicationDetailViewModelActions {
    private struct Constants {
        struct CellIdentifiers {
            static let DefaultCell = "DefaultCell"
            static let RightDetailCell = "RightDetailCell"
            static let TextFieldCell = "TextFieldCell"
            static let SelectableCell = "SelectableCell"
            static let StepperCell = "StepperCell"
        }

        enum SegueIdentifiers: String {
            case DismissMedicationDetail = "DismissMedicationDetail"
        }
    }

    var viewModel: MedicationDetailViewModel!

    private let disposable = CompositeDisposable()

    deinit {
        disposable.dispose()
    }

    // MARK: - Actions

    @IBAction private func save(sender: UIBarButtonItem?) {
        sender?.enabled = false
        viewModel.saveChanges.apply(())
            |> start(completed: { [unowned self, weak sender] in
                sender?.enabled = true
                self.cancel(sender)
            })
    }

    @IBAction private func cancel(sender: UIBarButtonItem?) {
        performSegueWithIdentifier(Constants.SegueIdentifiers.DismissMedicationDetail.rawValue, sender: sender)
    }

    // MARK: - Configuration

    private func configureNavigationItem() {
        func configureTitle() {
            let property = viewModel.name.map { (name: String?) -> String in
                if let name = name where !name.isEmpty {
                    return name
                } else {
                    return NSLocalizedString("New Medication", comment: "Medication detail view title if medication has empty name")
                }
            }

            disposable += property.producer.start(next: { [unowned self] title in
                self.navigationItem.title = title
            })
        }

        func configureBarButtonItems() {
            let save = navigationItem.rightBarButtonItem ?? undefined("Navigation item's right bar button item not set")
            disposable += viewModel.canSave.producer.start(next: { [weak save] canSave in
                save?.enabled = canSave
            })
        }

        configureTitle()
        configureBarButtonItems()
    }

    private func configureTableView() {
        formController.form = viewModel.form
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // `precondition` the view model
        precondition(viewModel != nil, "viewModel was not assigned before MedicationDetailViewController.viewDidLoad()")

        configureNavigationItem()
        configureTableView()
    }

    // MARK: - Form

    func updateFields() {
        formController.form = formController.form
        tableView.reloadData()
    }
}
