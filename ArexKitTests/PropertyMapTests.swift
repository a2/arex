import ArexKit
import ReactiveCocoa
import XCTest

class PropertyMapTests: XCTestCase {
    func testConstantPropertyMap() {
        let property = ConstantProperty("Hello, world!")
        let newProperty = property.map { $0.characters.count }
        XCTAssertEqual(newProperty.value, 13)
    }

    func testMutablePropertyMap() {
        let property = MutableProperty("Hello, world!")
        let newProperty = property.map { $0.characters.count }
        XCTAssertEqual(newProperty.value, 13)

        property.value = "Good night, moon!"
        XCTAssertEqual(newProperty.value, 17)
    }
}
