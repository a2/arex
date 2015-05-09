import ArexKit
import ReactiveCocoa
import UIKit

class MedicationDetailViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    private struct Constants {
        struct CellIdentifiers {
            static let DefaultCell = "DefaultCell"
            static let RightDetailCell = "RightDetailCell"
            static let TextFieldCell = "TextFieldCell"
            static let SelectableCell = "SelectableCell"
            static let StepperCell = "StepperCell"
        }

        struct SegueIdentifiers {
            static let DismissModalEditor = "DismissModalEditor"
        }
    }

    private enum StepperTag: Int {
        case Integer = 1000
        case Date
    }

    var viewModel: MedicationDetailViewModel!

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

    deinit {
        disposable.dispose()
    }

    private lazy var listItemNumberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formattingContext = .ListItem
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter
    }()

    private lazy var standaloneNumberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formattingContext = .Standalone
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter
    }()

    // MARK: - Calendar

    private let calendar = NSCalendar.currentCalendar()

    private func daysSinceReferenceDate(date: NSDate) -> Double {
        let components = calendar.components(.CalendarUnitDay, fromDate: NSDate(timeIntervalSinceReferenceDate: 0), toDate: date, options: nil)
        return Double(components.day)
    }

    private func date(daysSinceReferenceDate days: Double) -> NSDate {
        return calendar.dateByAddingUnit(.CalendarUnitDay, value: Int(days), toDate: NSDate(timeIntervalSinceReferenceDate: 0), options: nil) ?? undefined("Could not create NSDate instance with \(Int(days)) day(s) since reference date")
    }

    private lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = self.calendar
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.formattingContext = .Standalone
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter
    }()

    // MARK: - Configuration

    private func configureNavigationItem() {
        let property = map(viewModel.name) { name in
            return flush(name, not(isEmpty))
                ?? NSLocalizedString("New Medication", comment: "Medication detail view title if medication has empty name")
        }

        disposable += property.producer.start(next: { [unowned self] title in
            self.navigationItem.title = title
        })
    }

    private func configureTableView() {
        tableView.registerClass(RightDetailCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.RightDetailCell)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.DefaultCell)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.SelectableCell)
        tableView.registerNib(StepperCell.nib, forCellReuseIdentifier: Constants.CellIdentifiers.StepperCell)
        tableView.registerNib(TextFieldCell.nib, forCellReuseIdentifier: Constants.CellIdentifiers.TextFieldCell)
    }

    private func configureEditing() {
        updateUI(editing)

        let beginEditing = viewModel.beginEditing.executing.producer
            |> skip(1)
            |> filter { !$0 }
            |> map(replace(true))
        let saveChanges = viewModel.saveChanges.executing.producer
            |> skip(1)
            |> filter { !$0 }
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

    private func performTableViewUpdates(updates: [MedicationDetailViewModel.TableViewUpdate]) {
        tableView.beginUpdates()

        let animation: UITableViewRowAnimation = .Fade
        for update in updates {
            switch update {
            case let .Row(rowUpdate):
                switch rowUpdate {
                case let .Insert(indexPath):
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: animation)
                case let .Delete(indexPath):
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: animation)
                case let .Move(beforeIndexPath, afterIndexPath):
                    tableView.moveRowAtIndexPath(beforeIndexPath, toIndexPath: afterIndexPath)
                case let .Update(indexPath):
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: animation)
                }
            case let .Section(sectionUpdate):
                switch sectionUpdate {
                case let .Insert(section):
                    tableView.insertSections(NSIndexSet(index: section), withRowAnimation: animation)
                case let .Delete(section):
                    tableView.deleteSections(NSIndexSet(index: section), withRowAnimation: animation)
                case let .Move(beforeSection, afterSection):
                    tableView.moveSection(beforeSection, toSection: afterSection)
                case let .Update(section):
                    tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: animation)
                }
            }
        }

        tableView.endUpdates()
    }

    private func updateUI(editing: Bool) {
        performTableViewUpdates(viewModel.tableViewUpdates(forEditing: editing))
        updateNavigationItem(editing)
    }

    private func updateNavigationItem(editing: Bool) {
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

        tableView.beginUpdates()

        super.setEditing(editing, animated: animated)
        updateUI(editing)

        tableView.endUpdates()
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

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.tableViewSectionsCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewRowsCount(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch viewModel.tableViewCell(indexPath) {
        case let .Label(label: label):
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.DefaultCell, forIndexPath: indexPath) as? UITableViewCell
                ?? undefined("\(Constants.CellIdentifiers.DefaultCell) should be a UITableViewCell")
            cell.textLabel?.text = label
            return cell

        case let .Detail(label: label, value: value):
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.RightDetailCell, forIndexPath: indexPath) as? RightDetailCell
                ?? undefined("\(Constants.CellIdentifiers.RightDetailCell) should be a RightDetailCell")
            cell.textLabel?.text = label
            cell.detailTextLabel?.text = value
            return cell

        case let .TextField(label: label, value: value, placeholder: placeholder):
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.TextFieldCell, forIndexPath: indexPath) as? TextFieldCell
                ?? undefined("\(Constants.CellIdentifiers.TextFieldCell) should be a TextFieldCell")
            cell.titleLabel?.text = label

            if let textField = cell.textField {
                textField.addTarget(self, action: "textFieldEditingChanged:", forControlEvents: .EditingChanged)
                textField.delegate = self
                textField.text = value
                textField.placeholder = placeholder
            }

            return cell

        case let .IntegerStepper(value: value, minValue: minValue, maxValue: maxValue):
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.StepperCell, forIndexPath: indexPath) as? StepperCell
                ?? undefined("\(Constants.CellIdentifiers.StepperCell) should be a StepperCell")
            cell.titleLabel?.text = standaloneNumberFormatter.stringFromNumber(value)

            let doubleValue: Int -> Double = { Double($0) }
            cell.stepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)
            cell.stepper.maximumValue = maxValue.map(doubleValue) ?? Double.infinity
            cell.stepper.minimumValue = minValue.map(doubleValue) ?? -Double.infinity
            cell.stepper.tag = StepperTag.Integer.rawValue
            cell.stepper.value = doubleValue(value)

            return cell

        case let .DateStepper(value: value, minValue: minValue, maxValue: maxValue):
            let date = value ?? NSDate()
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.StepperCell, forIndexPath: indexPath) as? StepperCell
                ?? undefined("\(Constants.CellIdentifiers.StepperCell) should be a StepperCell")
            cell.titleLabel?.text = dateFormatter.stringFromDate(date)

            cell.stepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)
            cell.stepper.maximumValue = minValue.map(daysSinceReferenceDate) ?? Double.infinity
            cell.stepper.minimumValue = minValue.map(daysSinceReferenceDate) ?? -Double.infinity
            cell.stepper.tag = StepperTag.Date.rawValue
            cell.stepper.value = daysSinceReferenceDate(date)

            return cell

        case let .Selectable(label: label, selected: selected):
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.SelectableCell, forIndexPath: indexPath) as? UITableViewCell
                ?? undefined("\(Constants.CellIdentifiers.SelectableCell) should be a UITableViewCell")
            cell.accessoryType = selected ? .Checkmark : .None
            cell.textLabel?.text = label
            return cell
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch viewModel.tableViewCell(indexPath) {
        case .Selectable:
            return true
        case .Label, .Detail, .TextField, .IntegerStepper, .DateStepper:
            return false
        }
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        tableView.beginUpdates()
        if let updates = viewModel.tableViewDidSelectRow(indexPath) {
            performTableViewUpdates(updates)
        }
        tableView.endUpdates()
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let stepperCell = cell as? StepperCell {
            stepperCell.stepper.removeTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)
        } else if let textFieldCell = cell as? TextFieldCell, textField = textFieldCell.textField {
            textField.delegate = nil
            textField.removeTarget(self, action: "textFieldEditingChanged:", forControlEvents: .EditingChanged)
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.tableViewSectionHeaderTitle(section)
    }

    @IBAction private func stepperValueChanged(stepper: UIStepper) {
        if let cell = enclosingView(stepper, StepperCell.self), indexPath = tableView.indexPathForCell(cell) {
            let newValue = stepper.value

            let newText: String?
            let stepperTag = StepperTag(rawValue: stepper.tag) ?? undefined("StepperTag encapsulates all possible tag values")
            switch stepperTag {
            case .Integer:
                viewModel.integerStepperValueChanged(indexPath, newValue: Int(newValue))
                newText = standaloneNumberFormatter.stringFromNumber(newValue)
            case .Date:
                let newDate = date(daysSinceReferenceDate: newValue)
                viewModel.dateStepperValueChanged(indexPath, newValue: newDate)
                newText = dateFormatter.stringFromDate(newDate)
            }

            cell.titleLabel?.text =  newText
        }
    }

    // MARK: - Text Field

    private func textFieldDidUpdate(textField: UITextField) {
        if let cell = enclosingView(textField, TextFieldCell.self),
            indexPath = tableView.indexPathForCell(cell),
            action = viewModel.updateAction(indexPath: indexPath) {
                action.apply(textField.text ?? "").start()
        }
    }

    @IBAction private func textFieldEditingChanged(textField: UITextField) {
        textFieldDidUpdate(textField)
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return viewModel.editing.value
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textFieldDidEndEditing(textField: UITextField) {
        textFieldDidUpdate(textField)
    }
}
