import ArexKit
import UIKit

class MedicationsListCell: UITableViewCell {
    func configure(#viewModel: MedicationListCellViewModel) {
        textLabel?.text = viewModel.text
        detailTextLabel?.text = viewModel.detailText
    }
}
