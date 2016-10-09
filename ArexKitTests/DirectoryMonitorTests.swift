import ArexKit
import ReactiveCocoa
import XCTest

class DirectoryMonitorTests: XCTestCase {
    func makeTemporaryURL() -> NSURL {
        var fsrep = [Int8](count: Int(PATH_MAX), repeatedValue: 0)
        let template = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true).URLByAppendingPathComponent("DirectoryMonitorSpec.XXXXXXXX")
        template.getFileSystemRepresentation(&fsrep, maxLength: fsrep.count)
        return NSURL(fileURLWithFileSystemRepresentation: mkdtemp(&fsrep), isDirectory: true, relativeToURL: nil)
    }

    func removeTemporaryURL(directoryURL: NSURL) {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(directoryURL)
        } catch  {
            XCTFail("Could not remove directory \(directoryURL): \(error)")
        }
    }

    func testFailureForNonexistentDirectory() {
        let directoryURL = makeTemporaryURL()
        removeTemporaryURL(directoryURL)

        let expectation = expectationWithDescription("")

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            let result = monitorDirectory(directoryURL).first()
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
            .observeOn(QueueScheduler())
            .start(Observer(failed: { error in
                XCTFail("Unexpected failure: \(error)")
            }, next: { value in
                XCTAssertEqual(value, directoryURL)
                serialDisposable.dispose()
            }))

        do {
            let fileURL = directoryURL.URLByAppendingPathComponent("output.txt")
            try "Hello, world!".writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
