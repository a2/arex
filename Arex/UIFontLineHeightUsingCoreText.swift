import CoreText
import UIKit

extension UIFont {
    @objc(arex_lineHeightUsingCoreText)
    var lineHeightUsingCoreText: CGFloat {
        let font = self as CTFontRef
        return CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font)
    }
}
