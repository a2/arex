import UIKit
import XCTest

func XCTAssertEqualColors(@autoclosure expression1: () -> UIColor, @autoclosure _ expression2: () -> UIColor, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    var e1Red: CGFloat = 0
    var e1Green: CGFloat = 0
    var e1Blue: CGFloat = 0
    var e1Alpha: CGFloat = 0
    let e1Success = expression1().getRed(&e1Red, green: &e1Green, blue: &e1Blue, alpha: &e1Alpha)
    XCTAssertTrue(e1Success, message, file: file, line: line)

    var e2Red: CGFloat = 0
    var e2Green: CGFloat = 0
    var e2Blue: CGFloat = 0
    var e2Alpha: CGFloat = 0
    let e2Success = expression2().getRed(&e2Red, green: &e2Green, blue: &e2Blue, alpha: &e2Alpha)
    XCTAssertTrue(e2Success, message, file: file, line: line)

    let accuracy: CGFloat = 1.0 / 255.0
    XCTAssertEqualWithAccuracy(e1Red, e2Red, accuracy: accuracy, message, file: file, line: line)
    XCTAssertEqualWithAccuracy(e1Green, e2Green, accuracy: accuracy, message, file: file, line: line)
    XCTAssertEqualWithAccuracy(e1Blue, e2Blue, accuracy: accuracy, message, file: file, line: line)
    XCTAssertEqualWithAccuracy(e1Alpha, e2Alpha, accuracy: accuracy, message, file: file, line: line)
}

func XCTAssertNotNil<T>(@autoclosure expression: () -> T?, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression() != nil, message, file: file, line: line)
}

func XCTAssertNil<T>(@autoclosure expression: () -> T?, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression() == nil, message, file: file, line: line)
}

func XCTAssertEqual<T: Equatable>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T?, _ message:  String = "", file: String = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() == expression2(), message, file: file, line: line)
}

func XCTAssertEqualWithAccuracy<T: FloatingPointType>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T?, accuracy: T, _ message: String = "", file: String = __FILE__, line: UInt = __LINE__) {
    let value1 = expression1()
    let value2 = expression2()
    XCTAssertNotNil(value1, message, file: file, line: line)
    XCTAssertNotNil(value2, message, file: file, line: line)
    XCTAssertEqualWithAccuracy(value1!, value2!, accuracy: accuracy, message, file: file, line: line)
}
