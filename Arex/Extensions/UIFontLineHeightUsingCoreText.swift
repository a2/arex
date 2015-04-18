import CoreText
import UIKit

func lineHeight(font: UIFont) -> CGFloat {
    return CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font)
}
