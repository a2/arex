import LlamaKit
import Pistachio
import ReactiveCocoa

class MedicationDetailViewModel: ViewModel {
    private let immutableMedication: Medication
    private var medication: Medication
    private let medicationsController: MedicationsController

    lazy var numberFormatter: NSNumberFormatter = {
        var numberFormatter = NSNumberFormatter()
        numberFormatter.formattingContext = .Standalone
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter
    }()

    lazy var dateFormatter: NSDateFormatter = {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.formattingContext = .Standalone
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter
    }()

    init(medicationsController: MedicationsController, medication: Medication) {
        self.immutableMedication = medication
        self.medication = medication
        self.medicationsController = medicationsController

        super.init()

        // If `medication` is new, start in editing mode.
        self._editing.value = self.isNew
    }

    let _editing = MutableProperty<Bool>(false)

    lazy var editing: PropertyOf<Bool> = PropertyOf(self._editing)

    var wasNew: Bool {
        return get(MedicationLenses.uuid, immutableMedication) != nil
    }

    var isNew: Bool {
        return get(MedicationLenses.uuid, medication) != nil
    }

    lazy var canSave: PropertyOf<Bool> = {
        let transform: String? -> Bool = { $0.map(not(isEmpty)) ?? false }
        return map(self._name, transform)
    }()

    private lazy var _name: MutableProperty<String?> = MutableProperty(get(MedicationLenses.name, self.medication))

    lazy var name: PropertyOf<String?> = PropertyOf(self._name)

    var strength: String? {
        return get(MedicationLenses.strength, medication)
    }

    var dosesLeft: String? {
        return get(MedicationLenses.dosesLeft, medication).flatMap { dosesLeft in
            return numberFormatter.stringFromNumber(dosesLeft)
        }
    }

    var schedules: LazyRandomAccessCollection<MapCollectionView<[Schedule], ScheduleViewModel>> {
        return lazy(get(MedicationLenses.schedules, medication)).map({ ScheduleViewModel(schedule: $0) })
    }

    var lastFilledDate: String? {
        return get(MedicationLenses.lastFilledDate, medication).flatMap { lastFilledDate in
            return dateFormatter.stringFromDate(lastFilledDate)
        }
    }

    lazy var beginEditing: Action<Void, Void, NoError> = Action(enabledIf: map(self._editing, not)) { _ in
        return SignalProducer { (observer, _) in
            self._editing.value = true
            sendCompleted(observer)
        }
    }

    lazy var revertChanges: Action<Void, Void, NoError> = {
        let enabled = MutableProperty<Bool>(true)
        self._editing.producer
            |> combineLatestWith(self.saveChanges.executing.producer)
            |> map { (editing, saving) in editing && !saving }
            |> start(Event<Bool, NoError>.sink(next: enabled.put))

        return Action<Void, Void, NoError>(enabledIf: enabled) { _ in
            return SignalProducer { (observer, _) in
                self.medication = self.immutableMedication
                self._editing.value = false
                sendCompleted(observer)
            }
        }
    }()

    lazy var saveChanges: Action<Void, Void, MedicationsControllerError> = Action(enabledIf: self.canSave) { _ in
        return self.medicationsController.save(medication: &self.medication)
            |> on(completed: { [weak self] in
                if let _self = self {
                    _self._editing.value = false
                }
            })
    }

    lazy var updateName: Action<String?, Void, NoError> = Action<String?, Void, NoError> { name in
        let lens = MedicationDetailViewModelLenses.medication >>> MedicationLenses.name
        return SignalProducer { (observer, _) in
            set(lens, self, name)
            self._name.put(name)
            sendCompleted(observer)
        }
    }

    private lazy var dosesLeftValueTransformer: ValueTransformer<String?, Int?, NoError> = {
        let transformClosure: String? -> Result<Int?, NoError> = { (value: String?) in
            let result = value
                .flatMap(self.numberFormatter.numberFromString)
                .map { $0.integerValue }
            return success(result)
        }

        let reverseTransformClosure: Int? -> Result<String?, NoError> = { value in
            let result = value
                .map { NSNumber(integer: $0) }
                .flatMap(self.numberFormatter.stringFromNumber)
            return success(result)
        }

        return ValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
    }()

    lazy var updateDosesLeft: Action<String?, Void, NoError> = Action<String?, Void, NoError> { dosesLeft in
        let lens = transform(MedicationDetailViewModelLenses.medication >>> MedicationLenses.dosesLeft, flip(self.dosesLeftValueTransformer))
        return SignalProducer { (observer, _) in
            set(lens, success(self), success(dosesLeft))
            sendCompleted(observer)
        }
    }

    lazy var updateStrength: Action<String?, Void, NoError> = Action<String?, Void, NoError> { strength in
        let lens = MedicationDetailViewModelLenses.medication >>> MedicationLenses.strength
        return SignalProducer { (observer, _) in
            set(lens, self, strength)
            sendCompleted(observer)
        }
    }
}

private struct MedicationDetailViewModelLenses {
    static let medication = Lens(
        get: { $0.medication },
        set: { (inout viewModel: MedicationDetailViewModel, medication) in viewModel.medication = medication }
    )
}