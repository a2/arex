import Monocle
import Pistachio
import ReactiveCocoa

public class MedicationDetailViewModel {
    public enum ScheduleType: Int, Printable {
        case Daily
        case EveryXDays
        case Weekly
        case Monthly
        case NotCurrentlyTaken

        public static let count = 5

        public var description: String {
            switch self {
            case .Daily:
                return "Daily"
            case .EveryXDays:
                return "EveryXDays"
            case .Weekly:
                return "Weekly"
            case .Monthly:
                return "Monthly"
            case .NotCurrentlyTaken:
                return "NotCurrentlyTaken"
            }
        }
    }

    private let immutableMedication: Medication
    private var medication: Medication
    private let medicationsController: MedicationsController

    public init(medicationsController: MedicationsController, medication: Medication) {
        self.immutableMedication = medication
        self.medication = medication
        self.medicationsController = medicationsController

        // If `medication` is new, start in editing mode.
        self._editing.value = self.isNew
    }

    // MARK: Properties

    private let _editing = MutableProperty<Bool>(false)
    public lazy var editing: PropertyOf<Bool> = PropertyOf(self._editing)

    public var isNew: Bool {
        return get(MedicationLenses.uuid, immutableMedication) == nil
    }

    public var hasSaved: Bool {
        return get(MedicationLenses.uuid, medication) != nil
    }

    public lazy var canSave: PropertyOf<Bool> = {
        return map(self._name) { name in
            if let name = name {
                return !isEmpty(name)
            } else {
                return false
            }
        }
    }()

    private lazy var _name: MutableProperty<String?> = MutableProperty(get(MedicationLenses.name, self.medication))
    public lazy var name: PropertyOf<String?> = PropertyOf(self._name)

    public var strength: String? {
        return get(MedicationLenses.strength, medication)
    }

    private var hasStrength: Bool {
        return strength.map(not(isEmpty)) ?? false
    }

    // MARK: Schedule

    private var schedule: Schedule? {
        return get(MedicationLenses.schedule, self.medication)
    }

    public var scheduleType: ScheduleType {
        if let schedule = schedule {
            switch schedule {
            case .Daily:
                return .Daily
            case .EveryXDays:
                return .EveryXDays
            case .Weekly:
                return .Weekly
            case .Monthly:
                return .Monthly
            }
        } else {
            return .NotCurrentlyTaken
        }
    }

    // MARK: Actions

    public lazy var beginEditing: Action<Void, Void, NoError> = {
        let enabled = map(self._editing, !)
        let onStart: Void -> Void = { [unowned self] in
            self._editing.value = true
        }

        return Action(enabledIf: enabled) { _ in SignalProducer.empty |> on(started: onStart) }
    }()

    public lazy var revertChanges: Action<Void, Void, NoError> = {
        let enabled = MutableProperty<Bool>(true)
        self._editing.producer
            |> combineLatestWith(self.saveChanges.executing.producer)
            |> map { (editing, saving) in editing && !saving }
            |> start(Event.sink(next: enabled.put))

        let onStart: Void -> Void = { [unowned self] in
            self.medication = self.immutableMedication
            self._editing.value = false
        }

        return Action(enabledIf: enabled) { _ in SignalProducer.empty |> on(started: onStart) }
    }()

    public lazy var saveChanges: Action<Void, Void, MedicationsControllerError> = {
        let enabled = self.canSave
        let onComplete: Void -> Void = { [unowned self] in
            self._editing.value = false
        }

        return Action(enabledIf: enabled) { [unowned self] _ in
            return self.medicationsController.save(medication: &self.medication)
                |> on(completed: onComplete)
        }
    }()

    public lazy var updateName: Action<String?, Void, NoError> = {
        let lens = MedicationDetailViewModelLenses.medication >>> MedicationLenses.name
        return Action { name in
            return SignalProducer { [unowned self] (observer, _) in
                set(lens, self, name)
                self._name.value = name
                sendCompleted(observer)
            }
        }
    }()

    public lazy var updateStrength: Action<String?, Void, NoError> = {
        let lens = MedicationDetailViewModelLenses.medication >>> MedicationLenses.strength
        return Action { strength in
            return SignalProducer { [unowned self] (observer, _) in
                set(lens, self, strength)
                sendCompleted(observer)
            }
        }
    }()

    // MARK: Table View

    /*
    public func formDescriptor() -> XLFormDescriptor {
        let form = XLFormDescriptor()

    // GENERAL

        let general = XLFormSectionDescriptor()
        form.addFormSection(general)

        let name = XLFormRowDescriptor(tag: "name", rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Name", comment: "Name of medication; text field prompt"))
        name.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        name.required = true
        name.value = self.name.value
        general.addFormRow(name)

        let strength = XLFormRowDescriptor(tag: "strength", rowType: XLFormRowDescriptorTypeText, title: NSLocalizedString("Strength", comment: "Strength of medication; text field prompt"))
        strength.cellConfigAtConfigure["textField.textAlignment"] = NSTextAlignment.Right.rawValue
        strength.value = self.strength
        general.addFormRow(strength)

        let scheduleType = XLFormRowDescriptor(tag: "scheduleType", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: NSLocalizedString("Schedule Type", comment: "Schedule type; cell title"))
        let scheduleTypeOptions = [
            NSLocalizedString("Daily", comment: "Medication schedule type; name"),
            NSLocalizedString("Every X Days", comment: "Medication schedule type; name"),
            NSLocalizedString("Weekly", comment: "Medication schedule type; name"),
            NSLocalizedString("Monthly", comment: "Medication schedule type; name"),
            NSLocalizedString("Not Currently Taken", comment: "Medication schedule type; name"),
        ]
        scheduleType.required = true
        scheduleType.selectorOptions = scheduleTypeOptions
        scheduleType.value = scheduleTypeOptions[self.scheduleType.rawValue]
        general.addFormRow(scheduleType)
        
    // EVERY X DAYS
        
        let everyXDays = XLFormSectionDescriptor()
        everyXDays.title = scheduleTypeOptions[ScheduleType.EveryXDays.rawValue]
        everyXDays.hidden = "$scheduleType != \"\(scheduleTypeOptions[ScheduleType.EveryXDays.rawValue])\""
        form.addFormSection(everyXDays)

        let daysBetweenDoses = XLFormRowDescriptor(tag: "everyXDays.daysBetweenDoses", rowType: XLFormRowDescriptorTypeStepCounter, title: NSLocalizedString("Days Between Doses", comment: "'Every X days' schedule type; cell prompt"))
        daysBetweenDoses.required = true
        daysBetweenDoses.cellConfigAtConfigure["stepControl.minimumValue"] = 1
        daysBetweenDoses.cellConfigAtConfigure["stepControl.maximumValue"] = 28
        everyXDays.addFormRow(daysBetweenDoses)

        let startingDate = XLFormRowDescriptor(tag: "everyXDays.startingDate", rowType: XLFormRowDescriptorTypeDateInline, title: NSLocalizedString("Starting Date", comment: "'Every X days' schedule type; section header"))
        startingDate.required = true
        everyXDays.addFormRow(startingDate)

    // WEEKLY

        let weekly = XLFormSectionDescriptor()
        weekly.title = scheduleTypeOptions[ScheduleType.Weekly.rawValue]
        weekly.hidden = "$scheduleType != \"\(scheduleTypeOptions[ScheduleType.Weekly.rawValue])\""
        form.addFormSection(weekly)

        let weekDays: [String] = {
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale.currentLocale()
            return dateFormatter.standaloneWeekdaySymbols as! [String]
        }()

        let weeklyDaysDosesAreTaken = XLFormRowDescriptor(tag: "weekly.daysDosesAreTaken", rowType: XLFormRowDescriptorTypeMultipleSelector, title: NSLocalizedString("Days Doses Are Taken", comment: "'Weekly'/'Monthly' schedule type; cell prompt"))
        weeklyDaysDosesAreTaken.required = true
        weeklyDaysDosesAreTaken.selectorOptions = weekDays
        weekly.addFormRow(weeklyDaysDosesAreTaken)

    // MONTHLY

        let monthly = XLFormSectionDescriptor()
        monthly.title = scheduleTypeOptions[ScheduleType.Monthly.rawValue]
        monthly.hidden = "$scheduleType != \"\(scheduleTypeOptions[ScheduleType.Monthly.rawValue])\""
        form.addFormSection(monthly)

        let monthDays = Array(0..<28).map { i in toString(i + 1) }

        let monthlyDaysDosesAreTaken = XLFormRowDescriptor(tag: "monthly.daysDosesAreTaken", rowType: XLFormRowDescriptorTypeMultipleSelector, title: NSLocalizedString("Days Doses Are Taken", comment: "'Weekly'/'Monthly' schedule type; cell prompt"))
        monthlyDaysDosesAreTaken.required = true
        monthlyDaysDosesAreTaken.selectorOptions = monthDays
        monthly.addFormRow(monthlyDaysDosesAreTaken)

    // TIMES

        let times = XLFormSectionDescriptor.formSectionWithTitle(NSLocalizedString("Times", comment: "Medication alert times; section title"), sectionOptions: .CanInsert | .CanDelete, sectionInsertMode: .Button)
        times.multivaluedAddButton.title = NSLocalizedString("Add Time", comment: "Medication alert times; add button title")
        times.multivaluedRowTemplate = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeTimeInline, title: "")
        times.multivaluedTag = "times"
        form.addFormSection(times)

        let calendar = NSCalendar.currentCalendar()
        for time in get(MedicationLenses.times, medication).sorted(<) {
            let row = XLFormRowDescriptor(tag: nil, rowType: XLFormRowDescriptorTypeTimeInline, title: "")
            row.value = calendar.dateFromComponents(time.dateComponents)
            times.addFormRow(row)
        }

    // SET VALUES

        if let schedule = schedule {
            switch schedule {
            case .Daily:
                break
            case let .EveryXDays(interval, date):
                daysBetweenDoses.value = interval
                startingDate.value = date
            case let .Weekly(days):
                weeklyDaysDosesAreTaken.value = lazy(enumerate(weekDays))
                    .filter { i, day in (days & (1 << i)) != 0 }
                    .map { i, day in day }.array
            case let .Monthly(days):
                monthlyDaysDosesAreTaken.value = lazy(enumerate(monthDays))
                    .filter { i, day in (days & (1 << i)) != 0 }
                    .map { i, day in day }.array
            }
        }

        return form
    }
    */

    private class Form: NSObject, FXForm {
        class MonthDayStepperCell: FXFormStepperCell {
            override func setUp() {
                super.setUp()

                stepper.maximumValue = 28
                stepper.minimumValue = 1
                stepper.wraps = true
            }
        }

        weak var viewModel: MedicationDetailViewModel!
        let dateFormatter: NSDateFormatter = {
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale.currentLocale()
            return dateFormatter
        }()

        dynamic var name: String?
        dynamic var strength: String?
        dynamic var scheduleType: Int = ScheduleType.NotCurrentlyTaken.rawValue

        // Every X Days
        dynamic var daysBetweenDoses: Int = 1
        dynamic var startingDate: NSDate?

        // Weekly / Monthly
        dynamic var days: Int = 0

        dynamic var times: NSArray?
        
        func generalFields() -> [AnyObject] {
            let localizedScheduleTypes = [
                NSLocalizedString("Daily", comment: "Medication schedule type; name"),
                NSLocalizedString("Every X Days", comment: "Medication schedule type; name"),
                NSLocalizedString("Weekly", comment: "Medication schedule type; name"),
                NSLocalizedString("Monthly", comment: "Medication schedule type; name"),
                NSLocalizedString("Not Currently Taken", comment: "Medication schedule type; name"),
            ]

            return [
                [
                    FXFormFieldHeader: "",
                    FXFormFieldKey: "name",
                    "textField.autocapitalizationType": UITextAutocapitalizationType.Words.rawValue,
                ],
                "strength",
                [
                    FXFormFieldAction: "updateFields",
                    FXFormFieldKey: "scheduleType",
                    FXFormFieldOptions: localizedScheduleTypes,
                    FXFormFieldType: FXFormFieldTypeOption,
                ],
            ]
        }

        func scheduleTypeDependentFields() -> [AnyObject] {
            func everyXDaysFields() -> [AnyObject] {
                return [
                    [
                        FXFormFieldCell: MonthDayStepperCell.self,
                        FXFormFieldHeader: NSLocalizedString("Every X Days", comment: "Medication schedule type; name"),
                        FXFormFieldKey: "daysBetweenDoses",
                    ],
                    [
                        FXFormFieldDefaultValue: NSDate(),
                        FXFormFieldKey: "startingDate",
                    ]
                ]
            }

            func weeklyFields() -> [AnyObject] {
                return [

                ]
            }

            func monthlyFields() -> [AnyObject] {
                return [
                ]
            }

            let scheduleType = ScheduleType(rawValue: self.scheduleType) ?? undefined("rawValue \(self.scheduleType) unsupported by ScheduleType")
            switch scheduleType {
            case .EveryXDays:
                return everyXDaysFields()
            case .Weekly:
                return weeklyFields()
            case .Monthly:
                return monthlyFields()
            case .Daily, .NotCurrentlyTaken:
                return []
            }
        }

        func timeFields() -> [AnyObject] {
            class ValueTransformer: NSValueTransformer {
                let dateFormatter: NSDateFormatter = {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .NoStyle
                    dateFormatter.locale = NSLocale.currentLocale()
                    dateFormatter.timeStyle = .ShortStyle
                    return dateFormatter
                }()

                class override func allowsReverseTransformation() -> Bool {
                    return true
                }

                override func transformedValue(value: AnyObject?) -> AnyObject? {
                    return (value as? NSDate).map(dateFormatter.stringFromDate)
                }

                override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
                    return (value as? String).flatMap(dateFormatter.dateFromString)
                }
            }

            let valueTransformer = ValueTransformer()
            var template = [NSObject : AnyObject]()
            template[FXFormFieldPlaceholder] = valueTransformer.transformedValue(NSDate())
            template[FXFormFieldTitle] = NSLocalizedString("Add Time", comment: "Medication alert times; add button title")
            template[FXFormFieldType] = FXFormFieldTypeTime
            template[FXFormFieldValueTransformer] = valueTransformer
            template["datePicker.minuteInterval"] = 5

            return [
                [
                    FXFormFieldHeader: NSLocalizedString("Times", comment: "Medication alert times; section title"),
                    FXFormFieldInline: true,
                    FXFormFieldKey: "times",
                    FXFormFieldTemplate: template,
                ],
            ]
        }

        @objc func fields() -> [AnyObject]! {
            return generalFields() + scheduleTypeDependentFields() + timeFields()
        }

        @objc func excludedFields() -> [AnyObject]! {
            return [
                "dateFormatter",
                "viewModel",
            ]
        }
    }

    public let form: FXForm
}

private struct MedicationDetailViewModelLenses {
    static let medication = Lens(
        get: { $0.medication },
        set: { (inout viewModel: MedicationDetailViewModel, medication) in viewModel.medication = medication }
    )
}

public protocol MedicationDetailViewModelActions {
    func updateFields()
}
