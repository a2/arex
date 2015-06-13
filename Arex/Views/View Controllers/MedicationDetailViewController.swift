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

    // MARK: Bar Button Items

    private enum BarButtonItem: CustomStringConvertible {
        case Done
        case Edit
        case Save
        case Cancel

        var description: String {
            switch self {
            case .Done: return "done"
            case .Edit: return "edit"
            case .Save: return "save"
            case .Cancel: return "cancel"
            }
        }

        var systemItem: UIBarButtonSystemItem {
            switch self {
            case .Done: return .Done
            case .Edit: return .Edit
            case .Save: return .Save
            case .Cancel: return .Cancel
            }
        }
    }

    private func makeBarButtonItem(type: BarButtonItem) -> UIBarButtonItem {
        precondition(viewModel != nil, "MedicationDetailViewController.viewModel was not assigned before \(type)BarButtonItem loaded")

        let buttonAction: CocoaAction
        let enabled: PropertyOf<Bool>

        switch type {
        case .Done:
            let action: Action<Void, Void, NoError> = Action { _ in
                self.performSegueWithIdentifier(Constants.SegueIdentifiers.DismissMedicationDetail.rawValue, sender: nil)
                return .empty
            }

            buttonAction = CocoaAction(action, void)
            enabled = PropertyOf(ConstantProperty(true))
        case .Edit:
            buttonAction = CocoaAction(viewModel.beginEditing, void)
            enabled = viewModel.beginEditing.enabled
        case .Save:
            buttonAction = CocoaAction(viewModel.saveChanges, void)
            enabled = viewModel.saveChanges.enabled
        case .Cancel:
            buttonAction = CocoaAction(viewModel.revertChanges, void)
            enabled = viewModel.revertChanges.enabled
        }

        barButtonItemCocoaActions.insert(buttonAction)

        let barButtonItem = UIBarButtonItem(barButtonSystemItem: type.systemItem, target: buttonAction, action: CocoaAction.selector)
        enabled.producer.start(next: { [weak barButtonItem] enabled in
            barButtonItem?.enabled = enabled
        })
        return barButtonItem
    }

    private var barButtonItemCocoaActions = Set<CocoaAction>()
    private lazy var doneBarButtonItem: UIBarButtonItem = self.makeBarButtonItem(.Done)
    private lazy var editBarButtonItem: UIBarButtonItem = self.makeBarButtonItem(.Edit)
    private lazy var saveBarButtonItem: UIBarButtonItem = self.makeBarButtonItem(.Save)
    private lazy var cancelBarButtonItem: UIBarButtonItem = self.makeBarButtonItem(.Cancel)

    deinit {
        disposable.dispose()
    }

    // MARK: - Configuration

    private func configureNavigationItem() {
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

    private func configureTableView() {
        formController.form = viewModel.form
    }

    private func configureEditing() {
        editing = viewModel.editing.value
        updateUI(editing, false)

        let beginEditing = viewModel.beginEditing.executing.producer
            |> skip(1)
            |> filter(!)
            |> map(replace(true))
        let saveChanges = viewModel.saveChanges.executing.producer
            |> skip(1)
            |> filter(!)
            |> map(replace(false))
        disposable += SignalProducer(values: [beginEditing, saveChanges])
            |> flatten(.Merge)
            |> start(next: { [unowned self] editing in
                self.setEditing(editing, animated: true)
            })
        disposable += viewModel.revertChanges.executing.producer
            |> skip(1)
            |> start(next: { [unowned self] reverting in
                if reverting {
                    self.tableView.beginUpdates()
                    self.setEditing(false, animated: false)
                } else {
                    self.tableView.reloadData()
                    self.tableView.endUpdates()
                }
            })
    }

    // MARK: - UI Update

    private func updateUI(editing: Bool, _ animated: Bool) {
        updateNavigationItem(editing, animated)
    }

    private func updateNavigationItem(editing: Bool, _ animated: Bool) {
        let rightBarButtonItem, leftBarButtonItem: UIBarButtonItem?

        if editing {
            rightBarButtonItem = saveBarButtonItem
            leftBarButtonItem = cancelBarButtonItem
        } else {
            rightBarButtonItem = editBarButtonItem
            leftBarButtonItem = doneBarButtonItem
        }

        navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: animated)
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: animated)
    }

    // MARK: - View Life Cycle

    override func setEditing(editing: Bool, animated: Bool) {
        if !editing && viewModel.isNew {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }

        if !editing {
            view.endEditing(true)
        }

        super.setEditing(editing, animated: animated)
        updateUI(editing, animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // `precondition` the view model
        precondition(viewModel != nil, "viewModel was not assigned before MedicationDetailViewController.viewDidLoad()")

        configureNavigationItem()
        configureTableView()
        configureEditing()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if !editing && !viewModel.editing.value {
            navigationItem.rightBarButtonItem = editBarButtonItem
        }
    }

    // MARK: - Form

    func updateFields() {
        formController.form = formController.form
        tableView.reloadData()
    }
}
