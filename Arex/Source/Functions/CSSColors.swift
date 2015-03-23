import UIKit

/**
    Returns a color from a (hex) integer and an optional alpha value.

    :param: value A color's hex value
    :param: alpha An optional alpha value. Defaults to 1.0

    :returns: A color representation of hex
*/
func hex(value: Int, alpha: CGFloat = 1.0) -> UIColor {
    let r = CGFloat((value >> 16) & 0xFF) / 255.0
    let g = CGFloat((value >> 8) & 0xFF) / 255.0
    let b = CGFloat(value & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: alpha)
}

/**
    Returns a color from integral red, green, and blue values.

    :param: r The red component.
    :param: g The green component.
    :param: b The blue component.

    :returns: A color in the RGB colorspace.
*/
func rgb(r: Int, g: Int, b: Int) -> UIColor {
    return rgba(r, g, b, 1.0)
}

/**
    Returns a color from integral red, green, and blue values and an alpha value.

    :param: r The red component.
    :param: g The green component.
    :param: b The blue component.
    :param: a The alpha component.

    :returns: A color in the RGB colorspace.
*/
func rgba(r: Int, g: Int, b: Int, a: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
}
