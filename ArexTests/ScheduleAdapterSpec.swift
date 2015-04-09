import ArexKit
import Nimble
import Quick

class ScheduleAdapterSpec: QuickSpec {
    override func spec() {
        let scheduleAdapter = Adapters.schedule

        describe("encode()") {
            it("should encode Daily cases") {
                let schedule = Schedule.Daily
                let encoded = scheduleAdapter.encode(schedule)
                expect(encoded.isSuccess) == true
            }

            it("should encode EveryXDays cases") {
                let schedule = Schedule.EveryXDays(interval: 1, startDate: NSDate(timeIntervalSinceReferenceDate: 123456.78))
                let encoded = scheduleAdapter.encode(schedule)
                expect(encoded.isSuccess) == true
            }

            it("should encode Weekly cases") {
                let schedule = Schedule.Weekly(days: 0b0111110)
                let encoded = scheduleAdapter.encode(schedule)
                expect(encoded.isSuccess) == true
            }

            it("should encode Monthly cases") {
                let schedule = Schedule.Monthly(days: 0b0000010001010001010101010110)
                let encoded = scheduleAdapter.encode(schedule)
                expect(encoded.isSuccess) == true
            }
        }

        describe("decode()") {
            it("should decode Daily cases from encode()") {
                let schedule = Schedule.Daily
                let encoded = scheduleAdapter.encode(schedule)
                let decoded = scheduleAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == schedule
            }

            it("should decode EveryXDays cases from encode()") {
                let schedule = Schedule.EveryXDays(interval: 1, startDate: NSDate(timeIntervalSinceReferenceDate: 123456.78))
                let encoded = scheduleAdapter.encode(schedule)
                let decoded = scheduleAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == schedule
            }

            it("should decode Weekly cases from encode()") {
                let schedule = Schedule.Weekly(days: 0b0111110)
                let encoded = scheduleAdapter.encode(schedule)
                let decoded = scheduleAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == schedule
            }

            it("should decode Monthly cases from encode()") {
                let schedule = Schedule.Monthly(days: 0b0000010001010001010101010110)
                let encoded = scheduleAdapter.encode(schedule)
                let decoded = scheduleAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == schedule
            }
        }
    }
}