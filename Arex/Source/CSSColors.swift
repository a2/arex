import UIKit

func hex(value: Int, alpha: CGFloat = 1.0) -> UIColor {
    let r = CGFloat((value >> 16) & 0xFF) / 255.0
    let g = CGFloat((value >> 8) & 0xFF) / 255.0
    let b = CGFloat(value & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: alpha)
}

func rgb(r: Int, g: Int, b: Int) -> UIColor {
    return rgba(r, g, b, 1.0)
}

func rgba(r: Int, g: Int, b: Int, a: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
}
