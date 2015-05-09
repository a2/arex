import ArexKit
import Nimble
import Quick

class FlushSpec: QuickSpec {
    override func spec() {
        describe("flush()") {
            it("should change an invalid Equatable value into an Optional") {
                let value = 1
                let invalid = 1
                expect(flush(value, invalid)).to(beNil())
            }

            it("should ignore a valid Equatable value") {
                let value = 1
                let invalid = 0
                expect(flush(value, invalid)) == value
            }

            it("should change an invalid Equatable Optional value into an Optional") {
                let value: Int? = 1
                let invalid = 1
                expect(flush(value, invalid)).to(beNil())
            }

            it("should ignore a valid Equatable Optional value") {
                let value: Int? = 1
                let invalid = 0
                expect(flush(value, invalid)) == value
            }

            it("should change an invalid value into an Optional based on inclusion in a CollectionType") {
                let value = 0
                let valid = [1, 2, 3, 4, 5]
                expect(flush(value, valid)).to(beNil())
            }

            it("should ignore a valid value based on inclusion in a CollectionType") {
                let value = 3
                let valid = [1, 2, 3, 4, 5]
                expect(flush(value, valid)) == value
            }

            it("should change an invalid value into an Optional based on a validator predicate") {
                let value = 3
                let validator: Int -> Bool = { $0 % 2 == 0 }
                expect(flush(value, validator)).to(beNil())
            }

            it("should ignore a valid value based on a validator predicate") {
                let value = 4
                let validator: Int -> Bool = { $0 % 2 == 0 }
                expect(flush(value, validator)) == value
            }
        }
    }
}
