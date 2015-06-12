import ArexKit
import ReactiveCocoa
import XCTest

class ReactiveCocoaAdditionsTests: XCTestCase {
    func testCatchAll() {
        let result = SignalProducer<String, NSError>(error: NSError(domain: "", code: 0, userInfo: nil))
            |> flatMapError(catchAll)
            |> concat(SignalProducer(value: "Hello, world!"))
            |> first

        XCTAssertNotNil(result)
        XCTAssertNil(result!.error)
        XCTAssertEqual(result!.value, "Hello, world!")
    }

    func testReplace() {
        do {
            let transform: Int -> Int = replace(1)
            XCTAssertEqual(transform(2), 1)
            XCTAssertEqual(transform(3), 1)
            XCTAssertEqual(transform(4), 1)
        }

        do {
            let result = SignalProducer<String, NSError>(value: "Hello, world!")
                |> map(replace("Good night, moon!"))
                |> first

            XCTAssertNotNil(result)
            XCTAssertNil(result!.error)
            XCTAssertEqual(result!.value, "Good night, moon!")
        }
    }
}
