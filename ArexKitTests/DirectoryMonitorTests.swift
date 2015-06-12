import ArexKit
import ReactiveCocoa
import XCTest

class DirectoryMonitorTests: XCTestCase {
    func makeTemporaryURL() -> NSURL {
        var template = NSTemporaryDirectory().stringByAppendingPathComponent("DirectoryMonitorSpec.XXXXXXXX").fileSystemRepresentation()
        let directoryURL = template.withUnsafeMutableBufferPointer { (inout buffer: UnsafeMutableBufferPointer<Int8>) -> NSURL? in
            let path = mkdtemp(buffer.baseAddress)
            return NSURL(fileURLWithFileSystemRepresentation: path, isDirectory: true, relativeToURL: nil)
        }

        if let directoryURL = directoryURL {
            return directoryURL
        } else {
            let error = errno
            let string = String.fromCString(strerror(error))
            XCTFail("Could not create directory template: error \(error) \"\(string)\"")
            return undefined("XCTFail() should end the test")
        }
    }

    func removeTemporaryURL(directoryURL: NSURL) {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(directoryURL)
        } catch let error  {
            XCTFail("Could not remove directory \(directoryURL): \(error)")
        }
    }

    func testFailureForNonexistentDirectory() {
        let directoryURL = makeTemporaryURL()
        removeTemporaryURL(directoryURL)

        let expectation = expectationWithDescription("")

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            let result = monitorDirectory(directoryURL) |> first
            XCTAssertNotNil(result?.error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testSendsNextWhenDirectoryChanges() {
        let directoryURL = makeTemporaryURL()
        defer {
            removeTemporaryURL(directoryURL)
        }

        let serialDisposable = SerialDisposable()
        serialDisposable.innerDisposable = monitorDirectory(directoryURL)
            |> observeOn(QueueScheduler())
            |> start({ error in
                XCTFail("Unexpected failure: \(error)")
            }, next: { value in
                XCTAssertEqual(value, directoryURL)
                serialDisposable.dispose()
            })

        do {
            let fileURL = directoryURL.URLByAppendingPathComponent("output.txt")
            try "Hello, world!".writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
