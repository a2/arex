import ArexKit
import Nimble
import Quick
import ReactiveCocoa

class DirectoryMonitorSpec: QuickSpec {
    override func spec() {
        let makeTemporaryURL: Void -> NSURL = {
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
                fail("Could not create directory template: error \(error) \"\(string)\"")
                return undefined("fail() should end the test")
            }
        }

        let removeTemporaryURL: NSURL -> Void = { directoryURL in
            var error: NSError? = nil
            if !NSFileManager.defaultManager().removeItemAtURL(directoryURL, error: &error) {
                fail("Could not remove directory \(directoryURL): \(error)")
            }
        }

        describe("monitorDirectory(_:)") {
            it("cannot monitor a directory that does not exist") {
                let directoryURL = makeTemporaryURL()
                removeTemporaryURL(directoryURL)

                waitUntil() { done in
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UNSPECIFIED, 0)) {
                        switch monitorDirectory(directoryURL) |> first {
                        case .Some(.Failure(_)):
                            // "success" case
                            break
                        default:
                            fail("Expected failure to monitor non-existent directory")
                        }

                        done()
                    }
                }
            }

            it("sends the directoryURL argument when the directory changes") {
                let directoryURL = makeTemporaryURL()
                waitUntil() { done in
                    let serialDisposable = SerialDisposable()
                    serialDisposable.innerDisposable = monitorDirectory(directoryURL)
                        |> observeOn(QueueScheduler())
                        |> start(next: { _ in
                            serialDisposable.dispose()
                            done()
                        }, error: { error in
                            fail("Unexpected failure: \(error)")
                        })

                    var error: NSError? = nil
                    if !"Hello, world".writeToURL(directoryURL.URLByAppendingPathComponent("output.txt"), atomically: true, encoding: NSUTF8StringEncoding, error: &error) {
                        fail("Unexpected error: \(error)")
                    }
                }

                removeTemporaryURL(directoryURL)
            }
        }
    }
}
