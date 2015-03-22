import Pistachio

class MedicationDetailViewModel: ViewModel {
    private let medication: Medication

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

    init(medication: Medication) {
        self.medication = medication
    }

    var name: String? {
        return get(MedicationLenses.name, medication)
    }

    var strength: String? {
        return get(MedicationLenses.strength, medication)
    }

    var dosesLeft: String? {
        return get(MedicationLenses.dosesLeft, medication).flatMap { dosesLeft in
            return numberFormatter.stringFromNumber(dosesLeft)
        }
    }

    var lastFilledDate: String? {
        return get(MedicationLenses.lastFilledDate, medication).flatMap { lastFilledDate in
            return dateFormatter.stringFromDate(lastFilledDate)
        }
    }
}
