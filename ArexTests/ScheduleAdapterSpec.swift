import ArexKit
import Nimble
import Quick

class ScheduleAdapterSpec: QuickSpec {
    override func spec() {
        let scheduleAdapter = Adapters.schedule

        describe("encode()") {
            it("should encode Repeating cases") {
                let schedule = Schedule.Repeating(repeat: .Interval(repeat: 3, calendarUnit: .CalendarUnitDay), time: Time(hour: 7, minute: 59))
                let encoded = scheduleAdapter.encode(schedule)
                expect(encoded.isSuccess) == true
            }

            it("should encode Once cases") {
                let schedule = Schedule.Once(fireDate: NSDate(), timeZone: NSTimeZone(name: "America/New_York")!)
                let encoded = scheduleAdapter.encode(schedule)
                expect(encoded.isSuccess) == true
            }
        }

        describe("decode()") {
            it("should decode Repeating cases from encode()") {
                let schedule = Schedule.Repeating(repeat: .Interval(repeat: 3, calendarUnit: .CalendarUnitDay), time: Time(hour: 7, minute: 59))
                let encoded = scheduleAdapter.encode(schedule)
                let decoded = scheduleAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == schedule
            }

            it("should decode Once cases from encode()") {
                let schedule = Schedule.Once(fireDate: NSDate(), timeZone: NSTimeZone(name: "America/New_York")!)
                let encoded = scheduleAdapter.encode(schedule)
                let decoded = scheduleAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == schedule
            }
        }
    }
}