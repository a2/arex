import ArexKit
import Nimble
import Quick

class RepeatAdapterSpec: QuickSpec {
    override func spec() {
        let repeatAdapter = Adapters.repeat

        describe("encode()") {
            it("should encode Interval cases") {
                let repeat = Repeat.Interval(repeat: 3, calendarUnit: .CalendarUnitDay)
                let encoded = repeatAdapter.encode(repeat)
                expect(encoded.isSuccess) == true
            }

            it("should encode Weekly cases") {
                let repeat = Repeat.Weekly(weekdays: Weekdays(rawValue: 0b0111110))
                let encoded = repeatAdapter.encode(repeat)
                expect(encoded.isSuccess) == true
            }

            it("should encode MonthlyByDay cases") {
                let repeat = Repeat.MonthlyByDay(day: 15)
                let encoded = repeatAdapter.encode(repeat)
                expect(encoded.isSuccess) == true
            }

            it("should encode MonthlyByWeek cases") {
                let repeat = Repeat.MonthlyByWeek(week: 3, day: 3)
                let encoded = repeatAdapter.encode(repeat)
                expect(encoded.isSuccess) == true
            }
        }

        describe("decode()") {
            it("should decode Interval cases from encode()") {
                let repeat = Repeat.Interval(repeat: 3, calendarUnit: .CalendarUnitDay)
                let encoded = repeatAdapter.encode(repeat)
                let decoded = repeatAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == repeat
            }

            it("should decode Weekly cases from encode()") {
                let repeat = Repeat.Weekly(weekdays: Weekdays(rawValue: 0b0111110))
                let encoded = repeatAdapter.encode(repeat)
                let decoded = repeatAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == repeat
            }

            it("should decode MonthlyByDay cases from encode()") {
                let repeat = Repeat.MonthlyByDay(day: 15)
                let encoded = repeatAdapter.encode(repeat)
                let decoded = repeatAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == repeat
            }

            it("should decode MonthlyByWeek cases from encode()") {
                let repeat = Repeat.MonthlyByWeek(week: 3, day: 3)
                let encoded = repeatAdapter.encode(repeat)
                let decoded = repeatAdapter.decode(encoded.value!)
                expect(decoded.isSuccess) == true
                expect(decoded.value!) == repeat
            }
        }
    }
}
