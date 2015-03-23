import ArexKit
import Nimble
import Quick

class IndexPathSpec: QuickSpec {
    override func spec() {
        describe("NSIndexPath(indexes:)") {
            it("should create an index path with the specified indexes") {
                let indexPath = NSIndexPath(indexes: [1, 2, 3])
                let expected = { Void -> NSIndexPath in
                    var indexPath = NSIndexPath()
                    indexPath = indexPath.indexPathByAddingIndex(1)
                    indexPath = indexPath.indexPathByAddingIndex(2)
                    indexPath = indexPath.indexPathByAddingIndex(3)
                    return indexPath
                }()
                expect(indexPath) == expected
            }
        }

        describe("NSIndexPath(_:)") {
            it("should create an index path with the specified indexes") {
                let indexPath = NSIndexPath(1, 2, 3)
                let expected = { Void -> NSIndexPath in
                    var indexPath = NSIndexPath()
                    indexPath = indexPath.indexPathByAddingIndex(1)
                    indexPath = indexPath.indexPathByAddingIndex(2)
                    indexPath = indexPath.indexPathByAddingIndex(3)
                    return indexPath
                }()
                expect(indexPath) == expected
            }
        }
    }
}
