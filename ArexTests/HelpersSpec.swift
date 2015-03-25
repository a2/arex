import ArexKit
import Nimble
import Quick
import ReactiveCocoa

struct MyTrue: BooleanType {
    var boolValue: Bool {
        return true
    }
}

struct MyFalse: BooleanType {
    var boolValue: Bool {
        return false
    }
}

class HelpersSpec: QuickSpec {
    override func spec() {
        describe("boolValue()") {
            it("should return the truthinesss of a BooleanType") {
                expect(boolValue(true)) == true
                expect(boolValue(false)) == false
                expect(boolValue(MyTrue())) == true
                expect(boolValue(MyFalse())) == false
            }
        }

        describe("not()") {
            it("should negate the truthinesss of a BooleanType") {
                expect(not(true)) == false
                expect(not(false)) == true
                expect(not(MyTrue())) == false
                expect(not(MyFalse())) == true
            }
        }

        describe("not()()") {
            it("should negate a BooleanType returning validator predicate") {
                let empty = [Int]()
                let nonEmpty = [1, 2, 3]
                expect(not(isEmpty)(nonEmpty)) == true
                expect(not(isEmpty)(empty)) == false
            }
        }

        pending("undefined()") {
            it("cannot be tested because it calls fatalError()") {
                undefined("It causes the test run to crash") as Int
            }
        }

        pending("void()") {
            it("cannot be tested because it does nothing") {
                void()
                void("*shrug*")
            }
        }
    }
}
