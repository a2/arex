import ArexKit
import Nimble
import Quick

class CSSColorsSpec: QuickSpec {
    override func spec() {
        describe("hex") {
            it("should create a color from a hex value") {
                let value = 0x1e83c9

                let expectedRed: CGFloat = 0x1e / 255.0
                let expectedGreen: CGFloat = 0x83 / 255.0
                let expectedBlue: CGFloat = 0xc9 / 255.0
                let expectedAlpha: CGFloat = 1.0

                let color = hex(value)

                var actualRed = CGFloat(), actualGreen = CGFloat(), actualBlue = CGFloat(), actualAlpha = CGFloat()
                let success = color.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)
                expect(success) == true
                expect(actualRed) == expectedRed
                expect(actualGreen) == expectedGreen
                expect(actualBlue) == expectedBlue
                expect(actualAlpha) == expectedAlpha
            }

            it("should create a color from hex and alpha values") {
                let value = 0x1e83c9
                let alpha = 0.5

                let expectedRed: CGFloat = 0x1e / 255.0
                let expectedGreen: CGFloat = 0x83 / 255.0
                let expectedBlue: CGFloat = 0xc9 / 255.0
                let expectedAlpha: CGFloat = 0.5

                let color = hex(value, 0.5)

                var actualRed = CGFloat(), actualGreen = CGFloat(), actualBlue = CGFloat(), actualAlpha = CGFloat()
                let success = color.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)
                expect(success) == true
                expect(actualRed) == expectedRed
                expect(actualGreen) == expectedGreen
                expect(actualBlue) == expectedBlue
                expect(actualAlpha) == expectedAlpha
            }
        }

        describe("rgb") {
            it("should create a color from RGB components") {
                let red = 0x1e
                let green = 0x83
                let blue = 0xc9

                let expectedRed: CGFloat = 0x1e / 255.0
                let expectedGreen: CGFloat = 0x83 / 255.0
                let expectedBlue: CGFloat = 0xc9 / 255.0
                let expectedAlpha: CGFloat = 1.0

                let color = rgb(red, green, blue)

                var actualRed = CGFloat(), actualGreen = CGFloat(), actualBlue = CGFloat(), actualAlpha = CGFloat()
                let success = color.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)
                expect(success) == true
                expect(actualRed) == expectedRed
                expect(actualGreen) == expectedGreen
                expect(actualBlue) == expectedBlue
                expect(actualAlpha) == expectedAlpha
            }
        }

        describe("rgba") {
            it("should create a color from RGBA components") {
                let red = 0x1e
                let green = 0x83
                let blue = 0xc9
                let alpha: CGFloat = 0.5

                let expectedRed: CGFloat = 0x1e / 255.0
                let expectedGreen: CGFloat = 0x83 / 255.0
                let expectedBlue: CGFloat = 0xc9 / 255.0
                let expectedAlpha: CGFloat = 0.5

                let color = rgba(red, green, blue, alpha)

                var actualRed = CGFloat(), actualGreen = CGFloat(), actualBlue = CGFloat(), actualAlpha = CGFloat()
                let success = color.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)
                expect(success) == true
                expect(actualRed) == expectedRed
                expect(actualGreen) == expectedGreen
                expect(actualBlue) == expectedBlue
                expect(actualAlpha) == expectedAlpha
            }
        }
    }
}
