import ArexKit
import Pistachio

import Nimble
import Quick
import XCTest

class CompactSpec: QuickSpec {
    override func spec() {
        describe("compact") {
            context("Optional to Array") {
                it("should transform nil to an empty Array") {
                    let value: String? = nil
                    let compacted: [String] = compact(value)
                    expect(compacted.isEmpty) == true
                }

                it("should transform non-nil to a single-element Array") {
                    let value: String? = "Hello, world!"
                    let compacted: [String] = compact(value)
                    expect(compacted.isEmpty) == false
                    expect(compacted.count) == 1
                }
            }

            context("Optional to ContiguousArray") {
                it("should transform nil to an empty ContiguousArray") {
                    let value: String? = nil
                    let compacted: ContiguousArray<String> = compact(value)
                    expect(compacted.isEmpty) == true
                }

                it("should transform non-nil to a single-element ContiguousArray") {
                    let value: String? = "Hello, world!"
                    let compacted: ContiguousArray<String> = compact(value)
                    expect(compacted.isEmpty) == false
                    expect(compacted.count) == 1
                }
            }

            context("Optional to ArraySlice") {
                it("should transform nil to an empty ArraySlice") {
                    let value: String? = nil
                    let compacted: ArraySlice<String> = compact(value)
                    expect(compacted.isEmpty) == true
                }

                it("should transform non-nil to a single-element ArraySlice") {
                    let value: String? = "Hello, world!"
                    let compacted: ArraySlice<String> = compact(value)
                    expect(compacted.isEmpty) == false
                    expect(compacted.count) == 1
                }
            }

            context("Array<Optional> to Array") {
                it("should remove nil elements from the Array") {
                    let array: [Int?] = [1, 2, nil, 3, nil, 4, 5, 6, nil, nil]
                    let compacted: [Int] = compact(array)
                    expect(compacted) == [1, 2, 3, 4, 5, 6]
                }
            }

            context("ContiguousArray<Optional> to ContiguousArray") {
                it("should remove nil elements from the Array") {
                    let array: ContiguousArray<Int?> = [1, 2, nil, 3, nil, 4, 5, 6, nil, nil]
                    let compacted: ContiguousArray<Int> = compact(array)
                    expect(compacted.count) == 6
                    expect(compacted[0]) == 1
                    expect(compacted[1]) == 2
                    expect(compacted[2]) == 3
                    expect(compacted[3]) == 4
                    expect(compacted[4]) == 5
                    expect(compacted[5]) == 6
                }
            }

            context("ArraySlice<Optional> to ArraySlice") {
                it("should remove nil elements from the Array") {
                    let array: ArraySlice<Int?> = [1, 2, nil, 3, nil, 4, 5, 6, nil, nil]
                    let compacted: ArraySlice<Int> = compact(array)
                    expect(compacted.count) == 6
                    expect(compacted[0]) == 1
                    expect(compacted[1]) == 2
                    expect(compacted[2]) == 3
                    expect(compacted[3]) == 4
                    expect(compacted[4]) == 5
                    expect(compacted[5]) == 6
                }
            }

            context("Sequence<Optional> to Array") {
                it("should remove nil elements from the Array") {
                    let array: SequenceOf<Int?> = SequenceOf([1, 2, nil, 3, nil, 4, 5, 6, nil, nil])
                    let compacted: [Int] = compact(array)
                    expect(compacted) == [1, 2, 3, 4, 5, 6]
                }
            }

            context("CollectionType<Optional> to Array") {
                struct MyCollection<T>: CollectionType {
                    let inner: [T]

                    var startIndex: Int {
                        return inner.startIndex
                    }

                    var endIndex: Int {
                        return inner.endIndex
                    }

                    init(_ inner: [T]) {
                        self.inner = inner
                    }

                    subscript (index: Int) -> T {
                        return inner[index]
                    }

                    func generate() -> IndexingGenerator<[T]> {
                        return inner.generate()
                    }
                }
                
                it("should remove nil elements from the Array") {
                    let array: MyCollection<Int?> = MyCollection([1, 2, nil, 3, nil, 4, 5, 6, nil, nil])
                    let compacted: [Int] = compact(array)
                    expect(compacted) == [1, 2, 3, 4, 5, 6]
                }
            }
        }
    }
}
