import SAMTextView
import UIKit

class MedicationDetailViewController: UITableViewController {
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
    }

    var viewModel: MedicationDetailViewModel?

    // @IBOutlets
    @IBOutlet private weak var doctorLabel: UILabel!
    @IBOutlet private weak var dosesLeftTextField: UITextField!
    @IBOutlet private weak var lastFilledLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var noteTextView: SAMTextView!
    @IBOutlet private weak var pharmacyLabel: UILabel!
    @IBOutlet private weak var strengthTextField: UITextField!

    // MARK: View Life Cycle

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

    private func configureUI(editing: Bool) {
        if let viewModel = viewModel {
            nameTextField.text = viewModel.name

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
            if editing {
                doctor = NSLocalizedString("Doctor Dre", comment: "Placeholder doctor name; comical")
                pharmacy = NSLocalizedString("Animal Pharm", comment: "Placeholder pharmacy name; comical")
            } else {
                doctor = noneUnlessEditing
                pharmacy = noneUnlessEditing
            }
        } else {
            preconditionFailure("MedicationDetailViewController.viewModel was not assigned before the view loaded")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(nameTextField != nil, "MedicationDetailViewController.nameTextField was not configured in the storyboard")
        precondition(noteTextView != nil, "MedicationDetailViewController.noteTextView was not configured in the storyboard")
        precondition(tableView != nil, "MedicationDetailViewController.tableView was not configured in the storyboard")

        configureNoteTextView()
        configureTableView()
        configureUI(editing)
    }
}
