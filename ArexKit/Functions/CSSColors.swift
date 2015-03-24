import UIKit

private let maxComponent = 0xff

/**
    Returns a color from a (hex) integer and an optional alpha value.

    :param: value A color's hex value
    :param: alpha An optional alpha value. Defaults to 1.0

    :returns: A color representation of hex
*/
public func hex(value: Int, _ alpha: CGFloat = 1.0) -> UIColor {
    let r = CGFloat((value >> 16) & maxComponent) / CGFloat(maxComponent)
    let g = CGFloat((value >> 8) & maxComponent) / CGFloat(maxComponent)
    let b = CGFloat(value & maxComponent) / CGFloat(maxComponent)
    return UIColor(red: r, green: g, blue: b, alpha: alpha)
}

/**
    Returns a color from integral red, green, and blue values.

    :param: r The red component.
    :param: g The green component.
    :param: b The blue component.

    :returns: A color in the RGB colorspace.
*/
public func rgb(r: Int, g: Int, b: Int) -> UIColor {
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
public func rgba(r: Int, g: Int, b: Int, a: CGFloat) -> UIColor {
    return UIColor(red: CGFloat(r) / CGFloat(maxComponent), green: CGFloat(g) / CGFloat(maxComponent), blue: CGFloat(b) / CGFloat(maxComponent), alpha: a)
}
