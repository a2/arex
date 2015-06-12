import ArexKit
import XCTest

class CSSColorsTests: XCTestCase {
    func testHex() {
        XCTAssertEqualColors(hex(0x1e83c9), UIColor(red: 0x1e / 255.0, green: 0x82 / 255.0, blue: 0xc9 / 255.0, alpha: 1.0))
    }

    func testHexWithAlpha() {
        XCTAssertEqualColors(hex(0x1e83c9, 0.5), UIColor(red: 0x1e / 255.0, green: 0x82 / 255.0, blue: 0xc9 / 255.0, alpha: 0.5))
    }
}
