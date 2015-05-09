import Monocle
import Pistachio
import ReactiveCocoa

public class MedicationDetailViewModel {
    public enum Cell {
        case Label(label: String?)
        case Detail(label: String?, value: String?)
        case TextField(label: String?, value: String?, placeholder: String?)
        case IntegerStepper(value: Int, minValue: Int?, maxValue: Int?)
        case DateStepper(value: NSDate, minValue: NSDate?, maxValue: NSDate?)
        case Selectable(label: String, selected: Bool)
    }

    public enum ScheduleType: Int, Printable {
        case Daily
        case EveryXDays
        case Weekly
        case Monthly
        case NotCurrentlyTaken

        public static let count = 5

        private var additionalSectionCount: Int {
            switch self {
            case .Daily:
                return DailySectionIndex.count
            case .EveryXDays:
                return EveryXDaysSectionIndex.count
            case .Weekly:
                return WeeklySectionIndex.count
            case .Monthly:
                return MonthlySectionIndex.count
            case .NotCurrentlyTaken:
                return NotCurrentlyTakenSectionIndex.count
            }
        }

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

    public enum SectionIndex: Int {
        case General = 0
        case ScheduleType

        public static let count = 2
    }

    public enum GeneralSectionIndex: Int {
        case Name = 0
        case Strength

        public static let count = 2
    }

    public enum DailySectionIndex {
        public static let count = 0
    }

    public enum EveryXDaysSectionIndex: Int {
        case DaysBetweenDoses = 2
        case StartingDate

        public static let count = 2
    }

    public enum WeeklySectionIndex: Int {
        case DaysDosesAreTaken = 2

        public static let count = 1
    }

    public enum MonthlySectionIndex: Int {
        case DaysDosesAreTaken = 2

        public static let count = 1
    }

    public enum NotCurrentlyTakenSectionIndex {
        public static let count = 0
    }

    public enum TableViewUpdate: Printable {
        public enum SectionUpdate: Printable {
            case Insert(Int)
            case Delete(Int)
            case Move(Int, Int)
            case Update(Int)

            public var description: String {
                switch self {
                case let .Insert(section):
                    return "+[\(section)]"
                case let .Delete(section):
                    return "-[\(section)]"
                case let .Move(beforeSection, afterSection):
                    return "[\(beforeSection)]->[\(afterSection)]"
                case let .Update(section):
                    return "~[\(section)]"
                }
            }
        }

        public enum RowUpdate: Printable {
            case Insert(NSIndexPath)
            case Delete(NSIndexPath)
            case Move(NSIndexPath, NSIndexPath)
            case Update(NSIndexPath)

            public var description: String {
                switch self {
                case let .Insert(indexPath):
                    return "+(\(indexPath.section), \(indexPath.row))"
                case let .Delete(indexPath):
                    return "-(\(indexPath.section), \(indexPath.row))"
                case let .Move(beforeIndexPath, afterIndexPath):
                    return "(\(beforeIndexPath.section), \(beforeIndexPath.row))->(\(afterIndexPath.section), \(afterIndexPath.row))"
                case let .Update(indexPath):
                    return "~(\(indexPath.section), \(indexPath.row))"
                }
            }
        }

        case Section(SectionUpdate)
        case Row(RowUpdate)

        public var description: String {
            switch self {
            case let .Section(update):
                return update.description
            case let .Row(update):
                return update.description
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

    private struct EveryXDaysCache {
        var interval: Int
        var startDate: NSDate
    }

    private var everyXDaysCache: EveryXDaysCache? = nil

    private struct WeeklyCache {
        var days: Int
    }

    private var weeklyCache: WeeklyCache? = nil

    private struct MonthlyCache {
        var days: Int
    }

    private var monthlyCache: MonthlyCache? = nil

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
        let enabled = map(self._editing, not)
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

    public func updateAction(#indexPath: NSIndexPath) -> Action<String?, Void, NoError>? {
        if let index = SectionIndex(rawValue: indexPath.section) {
            switch index {
            case .General:
                let rowIndex = GeneralSectionIndex(rawValue: indexPath.row) ?? undefined("GeneralSectionIndex encapsulates all possible row values")
                switch rowIndex {
                case .Name:
                    return updateName
                case .Strength:
                    return updateStrength
                }
            case .ScheduleType:
                break
            }
        } else if let schedule = schedule {
            switch schedule {
            case .Daily:
                break
            case .EveryXDays:
                break
            case let .Weekly:
                break
            case let .Monthly:
                break
            }
        } else {
            // Not Currently Taken
        }

        return nil
    }

    // MARK: Table View

    public var tableViewSectionsCount: Int {
        return SectionIndex.count + scheduleType.additionalSectionCount
    }

    public func tableViewRowsCount(section: Int) -> Int {
        if let index = SectionIndex(rawValue: section) {
            switch index {
            case .General:
                let strengthVisible = editing.value || hasStrength
                return 1 + (strengthVisible ? 1 : 0)
            case .ScheduleType:
                return editing.value ? ScheduleType.count : 1
            }
        } else {
            switch scheduleType {
            case .EveryXDays:
                let sectionIndex = EveryXDaysSectionIndex(rawValue: section) ?? undefined("EveryXDaysSectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysBetweenDoses, .StartingDate:
                    return 1
                }
            case .Weekly:
                let sectionIndex = WeeklySectionIndex(rawValue: section) ?? undefined("WeeklySectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysDosesAreTaken:
                    return 28
                }
            case .Monthly:
                let sectionIndex = MonthlySectionIndex(rawValue: section) ?? undefined("MonthlySectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysDosesAreTaken:
                    return 28
                }
            case .Daily, .NotCurrentlyTaken:
                return undefined("ScheduleType.\(scheduleType) has no additional sections")
            }
        }
    }

    public func tableViewCell(indexPath: NSIndexPath) -> Cell {
        if let index = SectionIndex(rawValue: indexPath.section) {
            switch index {
            case .General:
                let rowIndex = GeneralSectionIndex(rawValue: indexPath.row) ?? undefined("GeneralSectionIndex encapsulates all possible row values")
                switch rowIndex {
                case .Name:
                    return .TextField(label: NSLocalizedString("Name", comment: "Name of medication; text field prompt"), value: get(MedicationLenses.name, medication), placeholder: nil)
                case .Strength:
                    return .TextField(label: NSLocalizedString("Strength", comment: "Strength of medication; text field prompt"), value: get(MedicationLenses.strength, medication), placeholder: nil)
                }
            case .ScheduleType:
                let scheduleType: ScheduleType
                if editing.value {
                    scheduleType = ScheduleType(rawValue: indexPath.row) ?? undefined("ScheduleType encapsulates all possible row values")
                } else {
                    scheduleType = self.scheduleType
                }

                let name: String
                switch scheduleType {
                case .Daily:
                    name = NSLocalizedString("Daily", comment: "Medication schedule type; name")
                case .EveryXDays:
                    name = NSLocalizedString("Every X Days", comment: "Medication schedule type; name")
                case .Weekly:
                    name = NSLocalizedString("Weekly", comment: "Medication schedule type; name")
                case .Monthly:
                    name = NSLocalizedString("Monthly", comment: "Medication schedule type; name")
                case .NotCurrentlyTaken:
                    name = NSLocalizedString("Not Currently Taken", comment: "Medication schedule type; name")
                }

                if editing.value {
                    return .Selectable(label: name, selected: scheduleType == self.scheduleType)
                } else {
                    return .Label(label: name)
                }
            }
        } else if let schedule = schedule {
            switch schedule {
            case .Daily:
                return undefined("ScheduleType.Daily has no additional sections")
            case let .EveryXDays(interval: interval, startDate: startDate):
                let sectionIndex = EveryXDaysSectionIndex(rawValue: indexPath.section) ?? undefined("EveryXDaysSectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysBetweenDoses:
                    return .IntegerStepper(value: interval, minValue: 1, maxValue: 28)
                case .StartingDate:
                    return .DateStepper(value: startDate, minValue: nil, maxValue: nil)
                }
            case let .Weekly(days: days):
                let sectionIndex = WeeklySectionIndex(rawValue: indexPath.section) ?? undefined("WeeklySectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysDosesAreTaken:
                    let selected = (days & (1 << indexPath.row)) != 0
                    return .Selectable(label: toString(indexPath.row + 1), selected: selected)
                }
            case let .Monthly(days: days):
                let sectionIndex = MonthlySectionIndex(rawValue: indexPath.section) ?? undefined("MonthlySectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysDosesAreTaken:
                    let selected = (days & (1 << indexPath.row)) != 0
                    return .Selectable(label: toString(indexPath.row + 1), selected: selected)
                }
            }
        } else {
            return undefined("ScheduleType.NotCurrentlyTaken has no additional sections")
        }
    }

    public func tableViewSectionHeaderTitle(section: Int) -> String? {
        if let index = SectionIndex(rawValue: section) {
            switch index {
            case .General:
                return nil
            case .ScheduleType:
                return NSLocalizedString("Schedule", comment: "Schedule type; section header")
            }
        } else {
            switch scheduleType {
            case .EveryXDays:
                let sectionIndex = EveryXDaysSectionIndex(rawValue: section) ?? undefined("EveryXDaysSectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysBetweenDoses:
                    return NSLocalizedString("Days Between Doses", comment: "'Every X days' schedule type; section header")
                case .StartingDate:
                    return NSLocalizedString("Starting Date", comment: "'Every X days' schedule type; section header")
                }
            case .Weekly:
                let sectionIndex = WeeklySectionIndex(rawValue: section) ?? undefined("WeeklySectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysDosesAreTaken:
                    return NSLocalizedString("Days Doses Are Taken", comment: "'Weekly'/'Monthly' schedule type; section header")
                }
            case .Monthly:
                let sectionIndex = MonthlySectionIndex(rawValue: section) ?? undefined("MonthlySectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysDosesAreTaken:
                    return NSLocalizedString("Days Doses Are Taken", comment: "'Weekly'/'Monthly' schedule type; section header")
                }
            case .Daily, .NotCurrentlyTaken:
                return undefined("ScheduleType.\(scheduleType) has no additional sections")
            }
        }
    }

    public func tableViewUpdates(forEditing editing: Bool) -> [TableViewUpdate] {
        var updates = [TableViewUpdate]()
        if editing {
            if !hasStrength {
                updates += [.Row(.Insert(NSIndexPath(SectionIndex.General.rawValue, GeneralSectionIndex.Strength.rawValue)))]
            }

            var indices = Array(0..<ScheduleType.count)
            indices.removeAtIndex(scheduleType.rawValue)
            updates += [.Row(.Update(NSIndexPath(SectionIndex.ScheduleType.rawValue, 0)))]
            updates += indices.map { .Row(.Insert(NSIndexPath(SectionIndex.ScheduleType.rawValue, $0))) }
        } else {
            if !hasStrength {
                updates += [.Row(.Delete(NSIndexPath(SectionIndex.General.rawValue, GeneralSectionIndex.Strength.rawValue)))]
            }

            var indices = Array(0..<ScheduleType.count)
            updates += [.Row(.Update(NSIndexPath(SectionIndex.ScheduleType.rawValue, indices.removeAtIndex(scheduleType.rawValue))))]
            updates += indices.map { .Row(.Delete(NSIndexPath(SectionIndex.ScheduleType.rawValue, $0))) }
        }

        return updates
    }

    public func integerStepperValueChanged(indexPath: NSIndexPath, newValue: Int) {
        if let schedule = schedule {
            switch schedule {
            case .Daily, .Weekly, .Monthly:
                break
            case let .EveryXDays(interval: interval, startDate: startDate):
                let sectionIndex = EveryXDaysSectionIndex(rawValue: indexPath.section) ?? undefined("EveryXDaysSectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysBetweenDoses:
                    break
                case .StartingDate:
                    let lens = MedicationDetailViewModelLenses.medication >>> MedicationLenses.schedule
                    set(lens, self, Schedule.EveryXDays(interval: newValue, startDate: startDate))
                }
            }
        }
    }

    public func dateStepperValueChanged(indexPath: NSIndexPath, newValue: NSDate) {
        if let schedule = schedule {
            switch schedule {
            case .Daily, .Weekly, .Monthly:
                break
            case let .EveryXDays(interval: interval, startDate: _):
                let sectionIndex = EveryXDaysSectionIndex(rawValue: indexPath.section) ?? undefined("EveryXDaysSectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysBetweenDoses:
                    let lens = MedicationDetailViewModelLenses.medication >>> MedicationLenses.schedule
                    set(lens, self, Schedule.EveryXDays(interval: interval, startDate: newValue))
                case .StartingDate:
                    break
                }
            }
        }
    }

    public func tableViewDidSelectRow(indexPath: NSIndexPath) -> [TableViewUpdate]? {
        var updates = [TableViewUpdate]()
        if let index = SectionIndex(rawValue: indexPath.section) {
            switch index {
            case .General:
                break
            case .ScheduleType:
                let oldRow = NSIndexPath(SectionIndex.ScheduleType.rawValue, scheduleType.rawValue)
                if let schedule = schedule {
                    switch schedule {
                    case .Daily:
                        break
                    case let .EveryXDays(interval: interval, startDate: startDate):
                        let indices = SectionIndex.count..<(SectionIndex.count + EveryXDaysSectionIndex.count)
                        updates += indices.map { .Section(.Delete($0)) }

                        everyXDaysCache = EveryXDaysCache(interval: interval, startDate: startDate)
                    case let .Weekly(days: days):
                        let indices = SectionIndex.count..<(SectionIndex.count + WeeklySectionIndex.count)
                        updates += indices.map { .Section(.Delete($0)) }

                        weeklyCache = WeeklyCache(days: days)
                    case let .Monthly(days: days):
                        let indices = SectionIndex.count..<(SectionIndex.count + MonthlySectionIndex.count)
                        updates += indices.map { .Section(.Delete($0)) }

                        monthlyCache = MonthlyCache(days: days)
                    }
                }

                let newSchedule: Schedule?
                let newScheduleType = ScheduleType(rawValue: indexPath.row) ?? undefined("ScheduleType encapsulates all possible row values")
                switch newScheduleType {
                case .Daily:
                    newSchedule = .Daily
                case .EveryXDays:
                    let indices = SectionIndex.count..<(SectionIndex.count + EveryXDaysSectionIndex.count)
                    updates += indices.map { .Section(.Insert($0)) }

                    let interval = everyXDaysCache?.interval ?? 1
                    let startDate = everyXDaysCache?.startDate ?? NSDate()
                    newSchedule = .EveryXDays(interval: interval, startDate: startDate)
                case .Weekly:
                    let indices = SectionIndex.count..<(SectionIndex.count + WeeklySectionIndex.count)
                    updates += indices.map { .Section(.Insert($0)) }

                    let days = weeklyCache?.days ?? 0
                    newSchedule = .Weekly(days: days)
                case .Monthly:
                    let indices = SectionIndex.count..<(SectionIndex.count + MonthlySectionIndex.count)
                    updates += indices.map { .Section(.Insert($0)) }

                    let days = monthlyCache?.days ?? 0
                    newSchedule = .Monthly(days: days)
                case .NotCurrentlyTaken:
                    newSchedule = nil
                }

                set(MedicationDetailViewModelLenses.medication >>> MedicationLenses.schedule, self, newSchedule)
                let newRow = NSIndexPath(SectionIndex.ScheduleType.rawValue, scheduleType.rawValue)
                if oldRow != newRow {
                    updates += [.Row(.Update(oldRow)), .Row(.Update(newRow))]
                }
            }
        } else if let schedule = schedule {
            switch schedule {
            case .EveryXDays:
                let sectionIndex = EveryXDaysSectionIndex(rawValue: indexPath.section) ?? undefined("EveryXDaysSectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysBetweenDoses:
                    break
                case .StartingDate:
                    break
                }
            case let .Weekly(days: days):
                let sectionIndex = WeeklySectionIndex(rawValue: indexPath.section) ?? undefined("WeeklySectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysDosesAreTaken:
                    var newDays = days
                    let bit = 1 << indexPath.row
                    if (days & bit) != 0 {
                        newDays &= ~bit
                    } else {
                        newDays |= bit
                    }

                    let newSchedule = Schedule.Weekly(days: newDays)
                    set(MedicationDetailViewModelLenses.medication >>> MedicationLenses.schedule, self, newSchedule)
                    updates += [.Row(.Update(indexPath))]
                }
            case let .Monthly(days: days):
                let sectionIndex = MonthlySectionIndex(rawValue: indexPath.section) ?? undefined("MonthlySectionIndex encapsulates all possible section values")
                switch sectionIndex {
                case .DaysDosesAreTaken:
                    var newDays = days
                    let bit = 1 << indexPath.row
                    if (days & bit) != 0 {
                        newDays &= ~bit
                    } else {
                        newDays |= bit
                    }

                    let newSchedule = Schedule.Monthly(days: newDays)
                    set(MedicationDetailViewModelLenses.medication >>> MedicationLenses.schedule, self, newSchedule)
                    updates += [.Row(.Update(indexPath))]
                }
            case .Daily:
                break
            }
        } else {
            // Not Currently Taken
        }

        return !isEmpty(updates) ? updates : nil
    }
}

private struct MedicationDetailViewModelLenses {
    static let medication = Lens(
        get: { $0.medication },
        set: { (inout viewModel: MedicationDetailViewModel, medication) in viewModel.medication = medication }
    )
}
