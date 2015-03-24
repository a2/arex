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

        describe("catchAll()") {
            it("should catch errors to an empty signal") {
                let result = SignalProducer<String, NSError>(error: NSError())
                    |> catch(catchAll)
                    |> concat(SignalProducer(value: "Hello, world!"))
                    |> first

                expect(result).notTo(beNil())
                expect(result!.error).to(beNil())
                expect(result!.value) == "Hello, world!"
            }
        }

        describe("map()") {
            it("should map a ConstantProperty from one type to another") {
                let property = ConstantProperty("Hello, world!")
                let newProperty = map(property, count)
                expect(newProperty.value) == 13
            }

            it("should map a Property from one type to another") {
                let property = MutableProperty("Hello, world!")
                let newProperty = map(property, count)
                expect(newProperty.value) == 13

                property.value = "Good night, moon!"
                expect(newProperty.value) == 17
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

        describe("replace()()") {
            it("should replace any input value with another value") {
                let transform: Int -> Int = replace(1)
                expect(transform(2)) == 1
                expect(transform(3)) == 1
                expect(transform(4)) == 1
            }

            it("should replace values with a constant value") {
                let result = SignalProducer<String, NSError>(value: "Hello, world!")
                    |> map(replace("Good night, moon!"))
                    |> first

                expect(result).notTo(beNil())
                expect(result!.error).to(beNil())
                expect(result!.value) == "Good night, moon!"
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
