import ArexKit
import Nimble
import Quick

class TimeAdapterSpec: QuickSpec {
    override func spec() {
        let timeAdapter = Adapters.time

        describe("encode()") {
            it("should encode Time values") {
                let time = Time(hour: 7, minute: 59)
                let encoded = timeAdapter.encode(time)
                expect(encoded.isSuccess) == true
            }
        }

        describe("decode()") {
            it("should decode Time values from encode()") {
                let time = Time(hour: 7, minute: 59)
                let encoded = timeAdapter.encode(time)
                let decoded = timeAdapter.decode(Time(hour: 0, minute: 0), from: encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == time
            }
        }
    }
}
