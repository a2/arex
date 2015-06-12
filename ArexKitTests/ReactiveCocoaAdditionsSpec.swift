import ArexKit
import Nimble
import Quick
import ReactiveCocoa

class ReactiveCocoaAdditionsSpec: QuickSpec {
    override func spec() {
        describe("catchAll()") {
            it("should catch errors to an empty signal") {
                let result = SignalProducer<String, NSError>(error: NSError(domain: "", code: 0, userInfo: nil))
                    |> flatMapError(catchAll)
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
                let newProperty = map(property) { $0.characters.count }
                expect(newProperty.value) == 13
            }

            it("should map a Property from one type to another") {
                let property = MutableProperty("Hello, world!")
                let newProperty = map(property) { $0.characters.count }
                expect(newProperty.value) == 13

                property.value = "Good night, moon!"
                expect(newProperty.value) == 17
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
    }
}