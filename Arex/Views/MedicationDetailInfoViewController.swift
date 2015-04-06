import ArexKit
import ReactiveCocoa
import SAMTextView
import UIKit

class MedicationDetailInfoViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    private struct Constants {
        struct TextView {
            // Used when adjusting scroll position due to carat position change.
            static let caratRectEdgeInsets = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)

            // Horizontal inset is taken care of in the storyboard.
            static let textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)

            // Set the LFP to 0 and use the storyboard to take care of the horizontal padding.
            static let lineFragmentPadding: CGFloat = 0

            // If you change this, update the storyboard too.
            static let horizontalPadding: CGFloat = 15

            // In multiples of the font's line height.
            static let minimumHeightMultiple = 3
        }

        struct SegueIdentifiers {
            static let DismissModalEditor = "DismissModalEditor"
        }
    }

    private enum SectionIndex: Int {
        case General = 0
        case Status
        case Contacts
        case Note
    }

    var viewModel: MedicationDetailInfoViewModel!

    private let disposable = CompositeDisposable()

    private var medicationDetailViewController: MedicationDetailViewController? {
        return parentViewController.map { $0 as! MedicationDetailViewController }
    }

    // MARK: Bar Button Items

    private enum BarButtonItem: Printable {
        case Edit
        case Save
        case Cancel

        var description: String {
            switch self {
            case .Edit: return "edit"
            case .Save: return "save"
            case .Cancel: return "cancel"
            }
        }

        var systemItem: UIBarButtonSystemItem {
            switch self {
            case .Edit: return .Edit
            case .Save: return .Save
            case .Cancel: return .Cancel
            }
        }
    }

    private func barButtonItem(type: BarButtonItem) -> UIBarButtonItem {
        precondition(viewModel != nil, "MedicationDetailInfoViewController.viewModel was not assigned before \(type)BarButtonItem loaded")

        let action: CocoaAction
        let enabled: PropertyOf<Bool>

        switch type {
        case .Edit:
            action = CocoaAction(viewModel.beginEditing, void)
            enabled = viewModel.beginEditing.enabled
        case .Save:
            action = CocoaAction(viewModel.saveChanges, void)
            enabled = viewModel.saveChanges.enabled
        case .Cancel:
            action = CocoaAction(viewModel.revertChanges, void)
            enabled = viewModel.revertChanges.enabled
        }

        barButtonItemCocoaActions.insert(action)

        var barButtonItem = UIBarButtonItem(barButtonSystemItem: type.systemItem, target: action, action: CocoaAction.selector)
        enabled.producer.start(next: { [weak barButtonItem] enabled in
            barButtonItem?.enabled = enabled
        })
        return barButtonItem
    }

    private var barButtonItemCocoaActions = Set<CocoaAction>()
    private lazy var saveBarButtonItem: UIBarButtonItem = self.barButtonItem(.Save)
    private lazy var cancelBarButtonItem: UIBarButtonItem = self.barButtonItem(.Cancel)
    private lazy var editBarButtonItem: UIBarButtonItem = self.barButtonItem(.Edit)

    // MARK: - @IBOutlets

    @IBOutlet private weak var doctorLabel: UILabel!
    @IBOutlet private weak var dosesLeftTextField: UITextField!
    @IBOutlet private weak var lastFilledLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var noteTextView: SAMTextView!
    @IBOutlet private weak var pharmacyLabel: UILabel!
    @IBOutlet private weak var strengthTextField: UITextField!

    deinit {
        disposable.dispose()
    }
    
    // MARK: - Configuration

    private func configureNavigationItem() {
        let property = map(viewModel.name) { name in
            return flush(name, not(isEmpty))
                ?? NSLocalizedString("New Medication", comment: "Medication detail view title if medication has empty name")
        }

        let observeDisposable = property.producer.start(next: { [unowned self] title in
            self.navigationItem.title = title
            self.medicationDetailViewController?.updateNavigationItem(self)
        })
        disposable.addDisposable(observeDisposable)
    }

    private func configureNoteTextView() {
        noteTextView.textContainer.lineFragmentPadding = Constants.TextView.lineFragmentPadding
        noteTextView.textContainerInset = Constants.TextView.textContainerInset

        let attributes = [
            NSFontAttributeName: noteTextView.font,
            NSForegroundColorAttributeName: Colors.textFieldPlaceholderColor,
        ]
        let string = NSLocalizedString("Type any additional notes about this medication here.", comment: "Text view placeholder; medication detail view")
        noteTextView.attributedPlaceholder = NSAttributedString(string: string, attributes: attributes)
    }

    private func configureEditing() {
        updateUI(editing)

        let editingDisposable = viewModel.editing.producer.start(next: { [weak self] editing in
            self?.setEditing(editing, animated: true)
        })
        disposable.addDisposable(editingDisposable)
    }

    // MARK: - UI Update

    private func updateUI(editing: Bool) {
        nameTextField.text = viewModel.name.value

        let unknown: NSAttributedString = {
            let attributes = [
                NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline),
                NSForegroundColorAttributeName: Colors.textFieldPlaceholderColor,
            ]
            let string = NSLocalizedString("Unknown", comment: "Label placeholder; unknown value")
            return NSAttributedString(string: string, attributes: attributes)
        }()

        if let strength = viewModel.strength {
            strengthTextField.text = strength
            strengthTextField.textColor = Colors.rightDetailCellTextColor
        } else {
            strengthTextField.attributedText = unknown
        }

        if let dosesLeft = viewModel.dosesLeft {
            dosesLeftTextField.text = dosesLeft
            dosesLeftTextField.textColor = Colors.rightDetailCellTextColor
        } else {
            dosesLeftTextField.attributedText = unknown
        }

        if let lastFilledDate = viewModel.lastFilledDate {
            lastFilledLabel.text = lastFilledDate
            lastFilledLabel.textColor = Colors.rightDetailCellTextColor
        } else {
            lastFilledLabel.attributedText = unknown
        }

        let doctor, pharmacy: String?
        let doctorPharmacyColor: UIColor

        // TODO #5: Add support for editing doctor, pharmacy

        if editing {
            doctor = NSLocalizedString("Doctor Dre", comment: "Placeholder doctor name; comical")
            pharmacy = NSLocalizedString("Animal Pharm", comment: "Placeholder pharmacy name; comical")
            doctorPharmacyColor = Colors.textFieldPlaceholderColor
        } else {
            doctor = unknown.string
            pharmacy = unknown.string
            doctorPharmacyColor = Colors.rightDetailCellTextColor
        }

        doctorLabel.text = doctor
        doctorLabel.textColor = doctorPharmacyColor

        pharmacyLabel.text = pharmacy
        pharmacyLabel.textColor = doctorPharmacyColor

        updateTableView(editing)
    }

    private func updateTableView(editing: Bool) {
        let rightBarButtonItem, leftBarButtonItem: UIBarButtonItem?

        if editing {
            rightBarButtonItem = saveBarButtonItem
            leftBarButtonItem = cancelBarButtonItem
        } else {
            rightBarButtonItem = editBarButtonItem
            leftBarButtonItem = nil
        }

        let animated = true
        navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: animated)
        navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: animated)
        medicationDetailViewController?.updateNavigationItem(self, animated: animated)
    }

    // MARK: - View Life Cycle

    override func didMoveToParentViewController(parent: UIViewController?) {
        // May move to parent VC after view loads.
        if let medicationDetailViewController = medicationDetailViewController {
            medicationDetailViewController.updateSegmentedControlEnabled(self, enabled: !editing)

            let toolbarHeight = medicationDetailViewController.navigationAccessoryToolbarFrame.size.height
            tableView.contentInset.top = toolbarHeight
            tableView.scrollIndicatorInsets.top = toolbarHeight
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        if !editing && viewModel.isNew {
            dismissViewControllerAnimated(true, completion: nil)
        }

        if !editing {
            view.endEditing(true)
        }

        tableView.beginUpdates()

        super.setEditing(editing, animated: animated)
        updateUI(editing)

        tableView.endUpdates()

        // Update segmented control enabled state (disabled if editing)
        medicationDetailViewController?.updateSegmentedControlEnabled(self, enabled: !editing, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // `precondition` the view model
        precondition(viewModel != nil, "viewModel was not assigned before MedicationDetailInfoViewController.viewDidLoad()")

        // `precondition` the @IBOutlets
        let outlets: [(UIView?, String)] = [
            (doctorLabel, "doctorLabel"),
            (dosesLeftTextField, "dosesLeftTextField"),
            (lastFilledLabel, "lastFilledLabel"),
            (nameTextField, "nameTextField"),
            (noteTextView, "noteTextView"),
            (pharmacyLabel, "pharmacyLabel"),
            (strengthTextField, "strengthTextField"),
        ]

        for (view, name) in outlets {
            precondition(view != nil, "\(name) was not assigned before MedicationDetailInfoViewController.viewDidLoad(); is the IBOutlet configured correctly")
        }

        configureNavigationItem()
        configureNoteTextView()
        configureEditing()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if !editing && !viewModel.editing.value {
            navigationItem.rightBarButtonItem = editBarButtonItem
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath rowIndexPath: NSIndexPath) -> CGFloat {
        let index = SectionIndex(rawValue: rowIndexPath.section) ?? undefined("SectionIndex encompasses all indexPath sections")
        switch index {
        case .Note:
            let textContainerInset = noteTextView.textContainerInset
            let horizontalInset = textContainerInset.left + textContainerInset.right
            let verticalInset = textContainerInset.top + textContainerInset.bottom

            let visibleText: NSAttributedString
            if let text = noteTextView.text where !isEmpty(text) {
                visibleText = noteTextView.attributedText
            } else {
                visibleText = noteTextView.attributedPlaceholder
            }

            let textViewWidth = tableView.bounds.width - 2 * Constants.TextView.horizontalPadding
            let boundingSize = CGSize(width: textViewWidth - horizontalInset, height: CGFloat.max)
            let boundingRect = visibleText.boundingRectWithSize(boundingSize, options: .UsesLineFragmentOrigin, context: nil)

            let height = ceil(boundingRect.height) + verticalInset
            let minHeight = CGFloat(Constants.TextView.minimumHeightMultiple) * ceil(noteTextView.font.lineHeightUsingCoreText) + verticalInset
            return max(minHeight, height) + 1 // 1 for separator
        default:
            return super.tableView(tableView, heightForRowAtIndexPath: rowIndexPath)
        }
    }

    // MARK: - Text Field

    @IBAction func textFieldEditingChanged(textField: UITextField) {
        switch textField {
        case nameTextField:
            let newValue = textField.text ?? ""
            viewModel.updateName.apply(newValue).start()
        case dosesLeftTextField:
            let newValue = textField.text ?? ""
            viewModel.updateDosesLeft.apply(newValue).start()
        case strengthTextField:
            let newValue = textField.text ?? ""
            viewModel.updateStrength.apply(newValue).start()
        default:
            break
        }
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return viewModel.editing.value
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case nameTextField:
            let newName = nameTextField.text ?? ""
            viewModel.updateName.apply(newName).start()
        case dosesLeftTextField:
            break
        case strengthTextField:
            break
        default:
            break
        }
    }

    // MARK: - Text View

    private func scrollNoteTextViewToTop(animated: Bool) {
        noteTextView.setContentOffset(CGPoint(), animated: animated)
    }

    private func scrollNoteTextViewCaratRectToVisible(animated: Bool) {
        if let startPosition = noteTextView.selectedTextRange?.start {
            let caratFrameInTextView = noteTextView.caretRectForPosition(startPosition)
            let caratFrameInTableView = tableView.convertRect(caratFrameInTextView, fromView: noteTextView)
            let visibleRect = UIEdgeInsetsInsetRect(caratFrameInTableView, Constants.TextView.caratRectEdgeInsets)
            tableView.scrollRectToVisible(visibleRect, animated: animated)
        }
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return viewModel.editing.value
    }

    func textViewDidChangeSelection(textView: UITextView) {
        UIView.performWithoutAnimation {
            self.scrollNoteTextViewCaratRectToVisible(false)
        }
    }

    func textViewDidChange(textView: UITextView) {
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()

            self.scrollNoteTextViewToTop(false)
            self.scrollNoteTextViewCaratRectToVisible(false)
        }
    }
}
