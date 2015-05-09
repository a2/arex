import UIKit

class TextFieldCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    class var nib: UINib {
        return UINib(nibName: "TextFieldCell", bundle: NSBundle(forClass: self))
    }
}
