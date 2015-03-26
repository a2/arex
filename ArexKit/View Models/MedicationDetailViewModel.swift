import LlamaKit
import Pistachio
import ReactiveCocoa

public class MedicationDetailViewModel {
    private let immutableMedication: Medication
    private var medication: Medication
    private let medicationsController: MedicationsController

    public lazy var dosesLeftFormatter: NSNumberFormatter = {
        var numberFormatter = NSNumberFormatter()
        numberFormatter.formattingContext = .Standalone
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter
    }()

    public lazy var lastFilledDateFormatter: NSDateFormatter = {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.formattingContext = .Standalone
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter
    }()

    public lazy var schedulesTimeFormatter: NSDateFormatter = {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()

    public lazy var schedulesDateFormatter: NSDateFormatter = {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.formattingContext = .MiddleOfSentence
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter
    }()

    public lazy var schedulesDateComponentsFormatter: NSDateComponentsFormatter = {
        var dateComponentsFormatter = NSDateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .Full
        dateComponentsFormatter.zeroFormattingBehavior = .DropAll
        return dateComponentsFormatter
    }()

    public init(medicationsController: MedicationsController, medication: Medication) {
        self.immutableMedication = medication
        self.medication = medication
        self.medicationsController = medicationsController

        // If `medication` is new, start in editing mode.
        self._editing.value = self.isNew
    }

    private let _editing = MutableProperty<Bool>(false)

    public lazy var editing: PropertyOf<Bool> = PropertyOf(self._editing)

    public var isNew: Bool {
        return get(MedicationLenses.uuid, immutableMedication) == nil
    }

    public var hasSaved: Bool {
        return get(MedicationLenses.uuid, medication) != nil
    }

    public lazy var canSave: PropertyOf<Bool> = {
        let transform: String? -> Bool = { $0.map(not(isEmpty)) ?? false }
        return map(self._name, transform)
    }()

    private lazy var _name: MutableProperty<String?> = MutableProperty(get(MedicationLenses.name, self.medication))

    public lazy var name: PropertyOf<String?> = PropertyOf(self._name)

    public var strength: String? {
        return get(MedicationLenses.strength, medication)
    }

    public var dosesLeft: String? {
        return get(MedicationLenses.dosesLeft, medication).flatMap { dosesLeft in
            return dosesLeftFormatter.stringFromNumber(dosesLeft)
        }
    }

    public var schedules: LazyRandomAccessCollection<MapCollectionView<[Schedule], ScheduleViewModel>> {
        return lazy(get(MedicationLenses.schedules, medication)).map({ schedule in
            return ScheduleViewModel(schedule: schedule, dateFormatter: self.schedulesDateFormatter, timeFormatter: self.schedulesTimeFormatter, dateComponentsFormatter: self.schedulesDateComponentsFormatter)
        })
    }

    public var lastFilledDate: String? {
        return get(MedicationLenses.lastFilledDate, medication).flatMap { lastFilledDate in
            return lastFilledDateFormatter.stringFromDate(lastFilledDate)
        }
    }

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

    private lazy var dosesLeftValueTransformer: ValueTransformer<String?, Int?, NoError> = {
        let transformClosure: String? -> Result<Int?, NoError> = { [unowned self] value in
            let result = value
                .flatMap(self.dosesLeftFormatter.numberFromString)
                .map { $0.integerValue }
            return success(result)
        }

        let reverseTransformClosure: Int? -> Result<String?, NoError> = { [unowned self] value in
            let result = value
                .map { NSNumber(integer: $0) }
                .flatMap(self.dosesLeftFormatter.stringFromNumber)
            return success(result)
        }

        return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
    }()

    public lazy var updateDosesLeft: Action<String?, Void, NoError> = {
        let lens = transform(MedicationDetailViewModelLenses.medication >>> MedicationLenses.dosesLeft, flip(self.dosesLeftValueTransformer))
        return Action { dosesLeft in
            return SignalProducer { [unowned self] (observer, _) in
                set(lens, self, dosesLeft)
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
}

private struct MedicationDetailViewModelLenses {
    static let medication = Lens(
        get: { $0.medication },
        set: { (inout viewModel: MedicationDetailViewModel, medication) in viewModel.medication = medication }
    )
}
