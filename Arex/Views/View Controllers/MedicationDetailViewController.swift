import ArexKit
import ReactiveCocoa
import UIKit

class MedicationDetailViewController: FXFormViewController, MedicationDetailViewModelActions {
    var viewModel: MedicationDetailViewModel!

    private let disposable = CompositeDisposable()

    deinit {
        disposable.dispose()
    }

    // MARK: - Actions

    @IBAction private func save(sender: UIBarButtonItem?) {
        sender?.enabled = false

        let observer = Observer<(), ActionError<MedicationsControllerError>>(completed: { [unowned self, weak sender] in
            sender?.enabled = true
            self.cancel(sender)
        })
        viewModel.saveChanges.apply().start(observer)
    }

    @IBAction private func cancel(sender: UIBarButtonItem?) {
        performSegue(Segue.DismissMedicationDetail, sender: sender)
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

            let observer = Observer<String, NoError>(next: { [unowned self] title in self.navigationItem.title = title })
            disposable += property.producer.start(observer)
        }

        func configureBarButtonItems() {
            let save = navigationItem.rightBarButtonItem ?? undefined("Navigation item's right bar button item not set")

            let observer = Observer<Bool, NoError>(next: { [weak save] canSave in save?.enabled = canSave })
            disposable += viewModel.canSave.producer.start(observer)
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
