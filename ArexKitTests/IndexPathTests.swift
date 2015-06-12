import ArexKit
import XCTest

class IndexPathTests: XCTestCase {
    func testIndexPathWithArray() {
        let indexPath = NSIndexPath(indexes: [1, 2, 3])

        let indexes = [1, 2, 3]
        let expected = NSIndexPath(indexes: indexes, length: 3)

        XCTAssertEqual(indexPath, expected)
    }

    func testIndexPathWithVarArgs() {
        let indexPath = NSIndexPath(1, 2, 3)

        let indexes = [1, 2, 3]
        let expected = NSIndexPath(indexes: indexes, length: 3)

        XCTAssertEqual(indexPath, expected)
    }
}
