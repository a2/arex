import UIKit

class StepperCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    let stepper: UIStepper

    class var nib: UINib {
        return UINib(nibName: "StepperCell", bundle: NSBundle(forClass: self))
    }

    required init(coder aDecoder: NSCoder) {
        self.stepper = UIStepper()
        super.init(coder: aDecoder)

        self.editingAccessoryView = self.stepper
    }
}
