import ArexKit
import XCTest

class MedicationSchedulingTests: XCTestCase {
    var calendar: NSCalendar!

    var date_1JAN2015: NSDate!
    var date_10JAN2015: NSDate!

    override func setUp() {
        calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

        date_1JAN2015 = calendar.dateFromComponents(dateComponents(1, 1, 2015))!
        date_10JAN2015 = calendar.dateFromComponents(dateComponents(1, 10, 2015))!

        super.setUp()
    }

    func time(hour: Int, _ minute: Int) -> Time {
        return Time(hour: hour, minute: minute)
    }

    func medication(schedule: Schedule, _ times: Time...) -> Medication {
        return Medication(schedule: schedule, times: times)
    }

    func dateComponents(month: Int, _ day: Int, _ year: Int) -> NSDateComponents {
        let dateComponents = NSDateComponents()
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.year = year
        return dateComponents
    }

    func dateComponents(month: Int, _ day: Int, _ year: Int, _ hour: Int, _ minute: Int) -> NSDateComponents {
        let dateComponents = self.dateComponents(month, day, year)
        dateComponents.hour = hour
        dateComponents.minute = minute
        return dateComponents
    }

    func date(month: Int, _ day: Int, _ year: Int, _ hour: Int, _ minute: Int) -> NSDate {
        let components = dateComponents(month, day, year, hour, minute)
        return calendar.dateFromComponents(components)!
    }

    func testDailyMedication() {
        let medication = self.medication(.Daily, time(1, 0), time(2, 0), time(3, 0), time(4, 0))
        let dates = medication.dates(inCalendar: calendar, from: date_1JAN2015, to: date_10JAN2015)

        let expectedDates = (1...10).flatMap { day in
            (1...4).map { hour in self.date(1, day, 2015, hour, 0) }
        }
        XCTAssertEqual(dates, expectedDates)
    }

    func testEveryXDaysMedication() {
        func test(interval: Int, _ days: [Int]) {
            let startDate = date(1, 1, 2015, 1, 0)

            let medication = self.medication(.EveryXDays(interval: interval, startDate: startDate), time(1, 0), time(2, 0), time(3, 0), time(4, 0))
            let dates = medication.dates(inCalendar: calendar, from: date_1JAN2015, to: date_10JAN2015)

            let expectedDates = days.flatMap { day in
                (1...4).map { hour in self.date(1, day, 2015, hour, 0) }
            }
            XCTAssertEqual(dates, expectedDates)
        }

        test(1, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        test(2, [1, 3, 5, 7, 9])
        test(3, [1, 4, 7, 10])
        test(4, [1, 5, 9])
        test(5, [1, 6])
    }

    func testWeeklyMedication() {
        /*
                January 2015
            Su Mo Tu We Th Fr Sa
                         1  2  3
             4  5  6  7  8  9 10
            11 12 13 14 15 16 17
            18 19 20 21 22 23 24
            25 26 27 28 29 30 31
        */

        func test(weekDays: Int, days: [Int]) {
            let medication = self.medication(.Weekly(days: weekDays), time(1, 0), time(2, 0), time(3, 0), time(4, 0))
            let dates = medication.dates(inCalendar: calendar, from: date_1JAN2015, to: date_10JAN2015)

            let expectedDates = days.flatMap { day in
                (1...4).map { hour in self.date(1, day, 2015, hour, 0) }
            }
            XCTAssertEqual(dates, expectedDates)
        }

        test(0b0000000, days: [])
        test(0b1111111, days: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        test(0b0000001, days: [4])
        test(0b0000010, days: [5])
        test(0b0000100, days: [6])
        test(0b0001000, days: [7])
        test(0b0010000, days: [1, 8])
        test(0b0100000, days: [2, 9])
        test(0b1000000, days: [3, 10])
    }

    func testMonthlyMedication() {
        func test(monthDays: Int, days: [Int]) {
            let medication = self.medication(.Monthly(days: monthDays), time(1, 0), time(2, 0), time(3, 0), time(4, 0))
            let dates = medication.dates(inCalendar: calendar, from: date_1JAN2015, to: date_10JAN2015)

            let expectedDates = days.flatMap { day in
                (1...4).map { hour in self.date(1, day, 2015, hour, 0) }
            }
            XCTAssertEqual(dates, expectedDates)
        }

        test(0b0000000_0000000_0000000_0000000, days: [])
        test(0b0000000_0000000_0000000_1111111, days: [1, 2, 3, 4, 5, 6, 7])
        test(0b1111111_1111111_1111000_0000000, days: [])
        test(0b1010101_0101010_1010101_0101010, days: [2, 4, 6, 8, 10])
        test(0b0101010_1010101_0101010_1010101, days: [1, 3, 5, 7, 9])
    }

    func testNotCurrentTakenMedication() {
        let medication = self.medication(.NotCurrentlyTaken)
        let dates = medication.dates(inCalendar: calendar, from: date_1JAN2015, to: date_10JAN2015)
        XCTAssertEqual(dates, [])
    }
}
