import ArexKit
import ReactiveCocoa
import SAMTextView
import UIKit

class MedicationDetailViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    private struct Constants {
        struct TextView {
            // Used when adjusting scroll position due to carat position change.
            static let caratRectEdgeInsets = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)

            // Horizontal inset is taken care of in the storyboard.
            static let textContainerVerticalInset: CGFloat = 10

            // If you change this, update the storyboard too.
            static let horizontalPadding: CGFloat = 15
        }

        struct CellIdentifiers {
            static let AddScheduleCell = "AddScheduleCell"
            static let ScheduleCell = "ScheduleCell"
        }

        struct SegueIdentifiers {
            static let DismissModalEditor = "DismissModalEditor"
        }
    }

    private enum SectionIndex: Int {
        case General = 0
        case Schedules
        case Status
        case Contacts
        case Note
    }

    var viewModel: MedicationDetailViewModel!

    private var schedulesCount: Int {
        return count(viewModel.schedules)
    }

    private let disposable = CompositeDisposable()

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
        precondition(viewModel != nil, "MedicationDetailViewController.viewModel was not assigned before \(type)BarButtonItem loaded")

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

        self.barButtonItemCocoaActions.insert(action)

        var barButtonItem = UIBarButtonItem(barButtonSystemItem: type.systemItem, target: action, action: CocoaAction.selector)
        enabled.producer.start(next: { [weak barButtonItem] enabled in
            if let _barButtonItem = barButtonItem {
                _barButtonItem.enabled = enabled
            }
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

        property.producer.start(next: { [weak self] title in
            // TODO #14: Remove workarounds for Xcode 6.3 beta 3 that were fixed in beta 4
            if let _self = self {
                _self.title = title
            }
        })
    }

    private func configureNoteTextView() {
        noteTextView.textContainer.lineFragmentPadding = 0
        noteTextView.textContainerInset = UIEdgeInsets(top: Constants.TextView.textContainerVerticalInset, left: 0, bottom: Constants.TextView.textContainerVerticalInset, right: 0)

        let attributes = [
            NSFontAttributeName: noteTextView.font,
            NSForegroundColorAttributeName: Colors.textFieldPlaceholderColor,
        ]
        let string = NSLocalizedString("Type any additional notes about this medication here.", comment: "Text view placeholder; medication detail view")
        noteTextView.attributedPlaceholder = NSAttributedString(string: string, attributes: attributes)
    }

    private func configureTableView() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.AddScheduleCell)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.ScheduleCell)
    }

    private func configureEditing() {
        updateUI(editing)

        let editingDisposable = viewModel.editing.producer.start(next: { [weak self] editing in
            // TODO #14: Remove workarounds for Xcode 6.3 beta 3 that were fixed in beta 4
            if let _self = self {
                _self.setEditing(editing, animated: true)
            }
        })
        disposable.addDisposable(editingDisposable)
    }

    // MARK: - UI Update

    private func updateUI(editing: Bool) {
        nameTextField.text = viewModel.name.value

        var unknownUnlessEditing: String? {
            return editing
                ? nil
                : NSLocalizedString("Unknown", comment: "Text field placeholder; unknown value")
        }

        var noneUnlessEditing: String? {
            return editing
                ? nil
                : NSLocalizedString("None", comment: "Doctor/pharmacy placeholder if not set")
        }

        strengthTextField.text = viewModel.strength
        dosesLeftTextField.text = viewModel.dosesLeft ?? unknownUnlessEditing
        if let dosesLeft = viewModel.dosesLeft {
            lastFilledLabel.text = dosesLeft
            lastFilledLabel.textColor = Colors.rightDetailCellTextColor
        } else {
            lastFilledLabel.text = editing
                ? viewModel.dateFormatter.stringFromDate(NSDate())
                : NSLocalizedString("Never", comment: "Text field placeholder; no date")
            lastFilledLabel.textColor = Colors.textFieldPlaceholderColor
        }

        let doctor, pharmacy: String?
        let doctorPharmacyColor: UIColor

        // TODO #5: Add support for editing doctor, pharmacy

        if editing {
            doctor = NSLocalizedString("Doctor Dre", comment: "Placeholder doctor name; comical")
            pharmacy = NSLocalizedString("Animal Pharm", comment: "Placeholder pharmacy name; comical")
            doctorPharmacyColor = Colors.textFieldPlaceholderColor
        } else {
            doctor = noneUnlessEditing
            pharmacy = noneUnlessEditing
            doctorPharmacyColor = Colors.rightDetailCellTextColor
        }

        doctorLabel.text = doctor
        doctorLabel.textColor = doctorPharmacyColor

        pharmacyLabel.text = pharmacy
        pharmacyLabel.textColor = doctorPharmacyColor

        updateTableView(editing)
    }

    private func updateTableView(editing: Bool) {
        let rowAnimation: UITableViewRowAnimation = .Fade
        if editing {
            navigationItem.setRightBarButtonItem(saveBarButtonItem, animated: true)
            navigationItem.setLeftBarButtonItem(cancelBarButtonItem, animated: true)

            if schedulesCount == 0 {
                tableView.deleteRowsAtIndexPaths([NSIndexPath(SectionIndex.Schedules.rawValue, 0)], withRowAnimation: rowAnimation)
            }

            tableView.insertRowsAtIndexPaths([NSIndexPath(SectionIndex.Schedules.rawValue, schedulesCount)], withRowAnimation: rowAnimation)
        } else {
            navigationItem.setRightBarButtonItem(editBarButtonItem, animated: true)
            navigationItem.setLeftBarButtonItem(nil, animated: true)

            tableView.deleteRowsAtIndexPaths([NSIndexPath(SectionIndex.Schedules.rawValue, schedulesCount)], withRowAnimation: rowAnimation)

            if schedulesCount == 0 {
                tableView.insertRowsAtIndexPaths([NSIndexPath(SectionIndex.Schedules.rawValue, 0)], withRowAnimation: rowAnimation)
            }
        }
    }

    // MARK: - View Life Cycle

    override func setEditing(editing: Bool, animated: Bool) {
        if !editing && viewModel.isNew && viewModel.hasSaved {
            performSegueWithIdentifier(Constants.SegueIdentifiers.DismissModalEditor, sender: nil)
        }

        if !editing {
            view.endEditing(true)
        }

        tableView.beginUpdates()

        super.setEditing(editing, animated: animated)

        updateUI(editing)

        tableView.endUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // `precondition` the view model
        precondition(viewModel != nil, "viewModel was not assigned before MedicationDetailViewController.viewDidLoad()")

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
            precondition(view != nil, "\(name) was not assigned before MedicationDetailViewController.viewDidLoad(); is the IBOutlet configured correctly")
        }

        configureNavigationItem()
        configureNoteTextView()
        configureTableView()
        configureEditing()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if !editing && !viewModel.editing.value {
            navigationItem.rightBarButtonItem = editBarButtonItem
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SectionIndex(rawValue: section) {
        case .Some(.Schedules):
            if viewModel.editing.value {
                return schedulesCount + 1
            } else {
                return max(schedulesCount, 1)
            }
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == SectionIndex.Schedules.rawValue {
            if editing && indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
                // Add Schedule

                var cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.AddScheduleCell, forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                cell.textLabel!.text = NSLocalizedString("Add Schedule", comment: "Medication detail view controller; cell button text; add medication dosage schedule")
                return cell
            } else if !editing && schedulesCount == 0 {
                // No Schedules

                var cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.ScheduleCell, forIndexPath: indexPath) as! UITableViewCell

                cell.textLabel!.text = NSLocalizedString("No Schedules", comment: "Medication detail view contorller; cell text; no schedules")
                cell.textLabel!.textColor = Colors.textFieldPlaceholderColor

                var fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
                fontDescriptor = fontDescriptor.fontDescriptorWithSymbolicTraits(.TraitItalic)!
                cell.textLabel!.font = UIFont(descriptor: fontDescriptor, size: 0.0)

                return cell
            } else {
                // Schedule

                var cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.AddScheduleCell, forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
                cell.textLabel!.text = toString(viewModel.schedules[indexPath.row])
                return cell
            }
        }

        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == SectionIndex.Schedules.rawValue
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return viewModel.editing.value && indexPath.section == SectionIndex.Schedules.rawValue
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section != SectionIndex.Schedules.rawValue {
            return .None
        } else if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
            return .Insert
        } else {
            return .Delete
        }
    }

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if editing && indexPath.section == SectionIndex.Schedules.rawValue && indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1 {
            // TODO: Segue implementation is unfinished
            fatalError("Segue implementation is unfinished")
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == SectionIndex.Schedules.rawValue {
            switch editingStyle {
            case .Insert:
                // TODO: Segue implementation is unfinished
                fatalError("Segue implementation is unfinished")
            case .Delete:
                // TODO: Deletion is not yet implemented
                fatalError("Deletion is not yet implemented")
            default:
                break
            }
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath rowIndexPath: NSIndexPath) -> CGFloat {
        let index = SectionIndex(rawValue: rowIndexPath.section) ?? undefined("SectionIndex encompasses all indexPath sections")

        switch index {
        case .Schedules:
            return super.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(SectionIndex.Schedules.rawValue, 0))

        case .Note:
            if noteTextView.bounds.width > 500 {
                // 500 is a pseudo-magic number. The storyboard lays out content at a 600 pt width
                // (minus 2 * 15 == 30 pt for padding is 570). Therefore, if the width is greater
                // than 500, the view hasn't layed out yet. We can set the frame explicitly here,
                // although it will be reset after an auto layout pass.
                noteTextView.frame.size.width = tableView.bounds.width - 2 * Constants.TextView.horizontalPadding
            }

            let textContainerInset = noteTextView.textContainerInset
            let verticalInset = textContainerInset.top + textContainerInset.bottom

            let height: CGFloat
            if count(noteTextView.text ?? "") > 0 {
                height = noteTextView.contentSize.height
            } else {
                let boundingWidth = noteTextView.bounds.width - textContainerInset.left - textContainerInset.right
                let boundingRect = noteTextView.attributedPlaceholder.boundingRectWithSize(CGSize(width: boundingWidth, height: CGFloat.max), options: .UsesLineFragmentOrigin, context: nil)
                height = ceil(boundingRect.height) + verticalInset
            }

            let minHeight = 3 * ceil(noteTextView.font.lineHeight) + verticalInset
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
