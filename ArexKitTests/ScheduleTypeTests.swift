import ArexKit
import XCTest

class ScheduleTypeTests: XCTestCase {
    func testDaily() {
        XCTAssertEqual(Schedule.Daily.scheduleType, ScheduleType.Daily)
    }

    func testEveryXDays() {
        XCTAssertEqual(Schedule.EveryXDays(interval: 1, startDate: NSDate()).scheduleType, ScheduleType.EveryXDays)
    }

    func testWeekly() {
        XCTAssertEqual(Schedule.Weekly(days: 0b0).scheduleType, ScheduleType.Weekly)
    }

    func testMonthly() {
        XCTAssertEqual(Schedule.Monthly(days: 0b0).scheduleType, ScheduleType.Monthly)
    }

    func testNotCurrentlyTaken() {
        XCTAssertEqual(Schedule.NotCurrentlyTaken.scheduleType, ScheduleType.NotCurrentlyTaken)
    }
}
