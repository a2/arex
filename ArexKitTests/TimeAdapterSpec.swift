import ArexKit
import Nimble
import Quick

class TimeAdapterSpec: QuickSpec {
    override func spec() {
        let timeAdapter = Adapters.time

        describe("transform()") {
            it("should transform Time values") {
                let time = Time(hour: 7, minute: 59)
                let encoded = timeAdapter.transform(time)
                expect(encoded.value).notTo(beNil())
            }
        }

        describe("reverseTransform()") {
            it("should reverse transform Time values from transform()") {
                let time = Time(hour: 7, minute: 59)
                let encoded = timeAdapter.transform(time)
                let decoded = timeAdapter.reverseTransform(encoded.value!)
                expect(decoded.value!) == time
            }
        }
    }
}
