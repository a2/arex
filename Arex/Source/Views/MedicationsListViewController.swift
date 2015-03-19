import UIKit

class MedicationsListViewController: UITableViewController {
    
    struct CellIdentifiers {
        static let MedicationCell = "MedicationCell"
    }
    
    private let medicationsListViewModel = MedicationsListViewModel(medicationsController: MedicationsController())

    // MARK: Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicationsListViewModel.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.MedicationCell, forIndexPath: indexPath) as! MedicationsListCell
        cell.configure(viewModel: medicationsListViewModel.cellViewModels[indexPath.row])
        return cell
    }
}
