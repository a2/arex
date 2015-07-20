import ArexKit
import XCTest

class NSDateComparableTests: XCTestCase {
    func date(ti: NSTimeInterval) -> NSDate {
        return NSDate(timeIntervalSinceReferenceDate: ti)
    }

    func testAscending() {
        let date1 = date(1)
        let date2 = date(2)
        XCTAssertTrue(date2 > date1)
        XCTAssertGreaterThan(date2, date1)
    }

    func testDescending() {
        let date1 = date(1)
        let date2 = date(2)
        XCTAssertTrue(date1 < date2)
        XCTAssertLessThan(date1, date2)
    }
}
