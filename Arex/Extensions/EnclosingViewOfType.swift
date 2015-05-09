import UIKit

func enclosingView<T>(view: UIView, type: T.Type) -> T? {
    var result: T? = nil
    var iter: UIView? = view
    while result == nil && iter != nil {
        result = iter as? T
        iter = iter!.superview
    }

    return result
}
