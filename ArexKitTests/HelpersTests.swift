import ArexKit
import XCTest

struct MyTrue: BooleanType {
    var boolValue: Bool {
        return true
    }
}

struct MyFalse: BooleanType {
    var boolValue: Bool {
        return false
    }
}

class HelpersTests: XCTestCase {
    func testBoolValue() {
        XCTAssertTrue(boolValue(true))
        XCTAssertFalse(boolValue(false))
        XCTAssertTrue(boolValue(MyTrue()))
        XCTAssertFalse(boolValue(MyFalse()))
    }

    func testNot() {
        XCTAssertFalse(not(boolValue)(true))
        XCTAssertTrue(not(boolValue)(false))
        XCTAssertFalse(not(boolValue)(MyTrue()))
        XCTAssertTrue(not(boolValue)(MyFalse()))
    }

    func testVoid() {
        void()
        void("*shrug*")
    }
}
