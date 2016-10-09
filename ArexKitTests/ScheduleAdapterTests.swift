import ArexKit
import MessagePack
import XCTest

class ScheduleAdapterTests: XCTestCase {
    let scheduleAdapter = Adapters.schedule

    func testDailyEncode() {
        let encoded = scheduleAdapter.transform(.Daily)
        XCTAssertNotNil(encoded.value)

        let expected: MessagePackValue = ["type": "daily"]
        XCTAssertEqual(encoded.value, expected)
    }

    func testDailyDecode() {
        let encoded: MessagePackValue = ["type": "daily"]

        let decoded = scheduleAdapter.reverseTransform(encoded)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, .Daily)
    }

    func testEveryXDaysEncode() {
        let encoded = scheduleAdapter.transform(.EveryXDays(interval: 3, startDate: NSDate(timeIntervalSince1970: 123.45)))
        XCTAssertNotNil(encoded.value)

        let expected: MessagePackValue = [
            "type": "everyXDays",
            "interval": 3,
            "startDate": 123.45,
        ]
        let value = encoded.value!
        XCTAssertNotNil(value.dictionaryValue)
        XCTAssertEqual(value["type"], expected["type"])
        XCTAssertEqual(value["interval"], expected["interval"])
        
        if let doubleValue = value["startDate"]?.doubleValue, expectedValue = expected["startDate"]?.doubleValue {
            XCTAssertEqualWithAccuracy(doubleValue, expectedValue, accuracy: 0.0001)
        } else {
            XCTFail()
        }
    }

    func testEveryXDaysDecode() {
        let encoded: MessagePackValue = [
            "type": "everyXDays",
            "interval": 3,
            "startDate": 123.45,
        ]

        let decoded = scheduleAdapter.reverseTransform(encoded)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, .EveryXDays(interval: 3, startDate: NSDate(timeIntervalSince1970: 123.45)))
    }

    func testWeeklyEncode() {
        let encoded = scheduleAdapter.transform(.Weekly(days: 0b0111110))
        XCTAssertNotNil(encoded.value)

        let expected: MessagePackValue = [
            "type": "weekly",
            "days": 0b0111110,
        ]
        XCTAssertEqual(encoded.value, expected)
    }

    func testWeeklyDecode() {
        let encoded: MessagePackValue = [
            "type": "weekly",
            "days": 0b0111110,
        ]

        let decoded = scheduleAdapter.reverseTransform(encoded)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, .Weekly(days: 0b0111110))
    }

    func testMonthlyEncode() {
        let encoded = scheduleAdapter.transform(.Monthly(days: 0b0000010001010001010101010110))
        XCTAssertNotNil(encoded.value)

        let expected: MessagePackValue = [
            "type": "monthly",
            "days": 0b0000010001010001010101010110,
        ]
        XCTAssertEqual(encoded.value, expected)
    }

    func testMonthlyDecode() {
        let encoded: MessagePackValue = [
            "type": "monthly",
            "days": 0b0000010001010001010101010110,
        ]

        let decoded = scheduleAdapter.reverseTransform(encoded)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, .Monthly(days: 0b0000010001010001010101010110))
    }
}
