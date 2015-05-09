import ArexKit
import Nimble
import Quick

class ScheduleAdapterSpec: QuickSpec {
    override func spec() {
        let scheduleAdapter = Adapters.schedule

        describe("transform()") {
            it("should transform Daily cases") {
                let schedule = Schedule.Daily
                let transformd = scheduleAdapter.transform(schedule)
                expect(transformd.value).notTo(beNil())
            }

            it("should transform EveryXDays cases") {
                let schedule = Schedule.EveryXDays(interval: 1, startDate: NSDate(timeIntervalSinceReferenceDate: 123456.78))
                let transformd = scheduleAdapter.transform(schedule)
                expect(transformd.value).notTo(beNil())
            }

            it("should transform Weekly cases") {
                let schedule = Schedule.Weekly(days: 0b0111110)
                let transformd = scheduleAdapter.transform(schedule)
                expect(transformd.value).notTo(beNil())
            }

            it("should transform Monthly cases") {
                let schedule = Schedule.Monthly(days: 0b0000010001010001010101010110)
                let transformd = scheduleAdapter.transform(schedule)
                expect(transformd.value).notTo(beNil())
            }
        }

        describe("reverseTransform()") {
            it("should decode Daily cases from transform()") {
                let schedule = Schedule.Daily
                let transformed = scheduleAdapter.transform(schedule)
                let decoded = scheduleAdapter.reverseTransform(transformed.value!)
                expect(decoded.value!) == schedule
            }

            it("should decode EveryXDays cases from transform()") {
                let schedule = Schedule.EveryXDays(interval: 1, startDate: NSDate(timeIntervalSinceReferenceDate: 123456.78))
                let transformed = scheduleAdapter.transform(schedule)
                let decoded = scheduleAdapter.reverseTransform(transformed.value!)
                expect(decoded.value!) == schedule
            }

            it("should decode Weekly cases from transform()") {
                let schedule = Schedule.Weekly(days: 0b0111110)
                let transformed = scheduleAdapter.transform(schedule)
                let decoded = scheduleAdapter.reverseTransform(transformed.value!)
                expect(decoded.value!) == schedule
            }

            it("should decode Monthly cases from transform()") {
                let schedule = Schedule.Monthly(days: 0b0000010001010001010101010110)
                let transformed = scheduleAdapter.transform(schedule)
                let decoded = scheduleAdapter.reverseTransform(transformed.value!)
                expect(decoded.value!) == schedule
            }
        }
    }
}