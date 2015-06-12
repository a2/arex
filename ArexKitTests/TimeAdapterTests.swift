import ArexKit
import MessagePack
import XCTest

class TimeAdapterTests: XCTestCase {
    let timeAdapter = Adapters.time

    func testTimeEncode() {
        let encoded = timeAdapter.transform(Time(hour: 7, minute: 59))
        XCTAssertNotNil(encoded.value)

        let expected: MessagePackValue = ["hour": 7, "minute": 59]
        XCTAssertEqual(encoded.value, expected)
    }

    func testTimeDecode() {
        let encoded: MessagePackValue = ["hour": 7, "minute": 59]

        let decoded = timeAdapter.reverseTransform(encoded)
        XCTAssertNotNil(decoded.value)
        XCTAssertEqual(decoded.value, Time(hour: 7, minute: 59))
    }
}
