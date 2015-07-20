import ArexKit
import XCTest

class ScheduleDescriptionTests: XCTestCase {
    func testDaily() {
        XCTAssertEqual(Schedule.Daily.description, "Daily")
    }

    func testEveryXDays() {
        let date = NSDate()
        XCTAssertEqual(Schedule.EveryXDays(interval: 1, startDate: date).description, "EveryXDays(interval: 1, startDate: \(date))")
    }

    func testWeekly() {
        XCTAssertEqual(Schedule.Weekly(days: 0b1010).description, "Weekly(days: 0b1010)")
    }

    func testMonthly() {
        XCTAssertEqual(Schedule.Monthly(days: 0b1010).description, "Monthly(days: 0b1010)")
    }

    func testNotCurrentlyTaken() {
        XCTAssertEqual(Schedule.NotCurrentlyTaken.description, "NotCurrentlyTaken")
    }
}
