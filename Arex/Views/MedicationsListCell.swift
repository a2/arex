import ArexKit
import UIKit

class MedicationsListCell: UITableViewCell {
    func configure(viewModel viewModel: MedicationListCellViewModel) {
        textLabel?.text = viewModel.text
        detailTextLabel?.text = viewModel.detailText
    }
}
