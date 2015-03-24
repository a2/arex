import Foundation

extension NSIndexPath {
    public convenience init(indexes: [Int]) {
        self.init(indexes: indexes, length: indexes.count)
    }

    public convenience init(_ indexes: Int...) {
        self.init(indexes: indexes)
    }
}
