import Foundation

func indexPath(indexes: [Int]) -> NSIndexPath {
    return NSIndexPath(indexes: indexes, length: indexes.count)
}

func indexPath(indexes: Int...) -> NSIndexPath {
    return NSIndexPath(indexes: indexes, length: indexes.count)
}
