import Foundation
import LlamaKit
import MessagePack_swift
import Pistachio

struct MessagePackValueTransformers {
    enum Error: Int, ErrorRepresentable {
        static let domain = "MessagePackValueTransformersError"

        case InvalidBool
        case InvalidInt
        case InvalidUInt
        case InvalidFloat
        case InvalidDouble
        case InvalidString
        case InvalidBinary
        case InvalidArray
        case InvalidMap
        case InvalidExtended
        case IncorrectExtendedType

        var code: Int {
            return rawValue
        }

        var description: String {
            switch self {
            case .InvalidBool:
                return "Could not decode Bool from MessagePackValue"
            case .InvalidInt:
                return "Could not decode Int from MessagePackValue"
            case .InvalidUInt:
                return "Could not decode UInt from MessagePackValue"
            case .InvalidFloat:
                return "Could not decode Float from MessagePackValue"
            case .InvalidDouble:
                return "Could not decode Double from MessagePackValue"
            case .InvalidString:
                return "Could not decode String from MessagePackValue"
            case .InvalidBinary:
                return "Could not decode Binary from MessagePackValue"
            case .InvalidArray:
                return "Could not decode Array from MessagePackValue"
            case .InvalidMap:
                return "Could not decode Map from MessagePackValue"
            case .InvalidExtended:
                return "Could not decode Extended from MessagePackValue"
            case .IncorrectExtendedType:
                return "Could not decode Extended of correct type from MessagePackValue"
            }
        }

        var failureReason: String? {
            return nil
        }
    }

    static let bool: ValueTransformer<Bool, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Bool(value))
    }, reverseTransformClosure: { value in
        if let value = value.boolValue {
            return success(value)
        } else {
            return failure(error(code: Error.InvalidBool))
        }
    })

    static func int<S: SignedIntegerType>() -> ValueTransformer<S, MessagePackValue, NSError> {
        return ValueTransformer(transformClosure: { value in
            return success(.Int(numericCast(value)))
        }, reverseTransformClosure: { value in
            if let value = value.integerValue {
                return success(numericCast(value))
            } else {
                return failure(error(code: Error.InvalidInt))
            }
        })
    }

    static func uint<U: UnsignedIntegerType>() -> ValueTransformer<U, MessagePackValue, NSError> {
        return ValueTransformer(transformClosure: { value in
            return success(.UInt(numericCast(value)))
        }, reverseTransformClosure: { value in
            if let value = value.unsignedIntegerValue {
                return success(numericCast(value))
            } else {
                return failure(error(code: Error.InvalidUInt))
            }
        })
    }

    static let float: ValueTransformer<Float32, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Float(value))
    }, reverseTransformClosure: { value in
        if let value = value.floatValue {
            return success(value)
        } else {
            return failure(error(code: Error.InvalidFloat))
        }
    })

    static let double: ValueTransformer<Float64, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Double(value))
    }, reverseTransformClosure: { value in
        if let value = value.doubleValue {
            return success(value)
        } else {
            return failure(error(code: Error.InvalidDouble))
        }
    })

    static let string: ValueTransformer<String, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.String(value))
    }, reverseTransformClosure: { value in
        if let value = value.stringValue {
            return success(value)
        } else {
            return failure(error(code: Error.InvalidString))
        }
    })

    static let binary: ValueTransformer<NSData, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Binary(value))
    }, reverseTransformClosure: { value in
        if let value = value.dataValue {
            return success(value)
        } else {
            return failure(error(code: Error.InvalidBinary))
        }
    })

    static let array: ValueTransformer<[MessagePackValue], MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Array(value))
    }, reverseTransformClosure: { value in
        if let value = value.arrayValue {
            return success(value)
        } else {
            return failure(error(code: Error.InvalidArray))
        }
    })

    static let map: ValueTransformer<[MessagePackValue : MessagePackValue], MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Map(value))
    }, reverseTransformClosure: { value in
        if let value = value.dictionaryValue {
            return success(value)
        } else {
            return failure(error(code: Error.InvalidMap))
        }
    })

    static func extended(type: Int8) -> ValueTransformer<NSData, MessagePackValue, NSError> {
        return ValueTransformer(transformClosure: { value in
            return success(.Extended(type: type, data: value))
        }, reverseTransformClosure: { value in
            if let (decodedType, data) = value.extendedValue {
                if decodedType == type {
                    return success(data)
                } else {
                    return failure(error(code: Error.IncorrectExtendedType))
                }
            } else {
                return failure(error(code: Error.InvalidExtended))
            }
        })
    }
}

func messagePackBool<A>(lens: Lens<A, Bool>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.bool)
}

func messagePackBool<A>(lens: Lens<A, Bool?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .Bool(false)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.bool, defaultTransformedValue))
}

func messagePackInt<A, S: SignedIntegerType>(lens: Lens<A, S>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.int())
}

func messagePackInt<A, S: SignedIntegerType>(lens: Lens<A, S?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .Int(0)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.int(), defaultTransformedValue))
}

func messagePackUInt<A, U: UnsignedIntegerType>(lens: Lens<A, U>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.uint())
}

func messagePackUInt<A, U: UnsignedIntegerType>(lens: Lens<A, U?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .UInt(0)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.uint(), defaultTransformedValue))
}

func messagePackFloat<A>(lens: Lens<A, Float32>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.float)
}

func messagePackFloat<A>(lens: Lens<A, Float32?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .Float(0)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.float, defaultTransformedValue))
}

func messagePackDouble<A>(lens: Lens<A, Float64>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.double)
}

func messagePackDouble<A>(lens: Lens<A, Float64?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .Double(0)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.double, defaultTransformedValue))
}

func messagePackString<A>(lens: Lens<A, String>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.string)
}

func messagePackString<A>(lens: Lens<A, String?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .String("")) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.string, defaultTransformedValue))
}

func messagePackBinary<A>(lens: Lens<A, NSData>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.binary)
}

func messagePackBinary<A>(lens: Lens<A, NSData?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .Binary(NSData())) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.binary, defaultTransformedValue))
}

func messagePackArray<A, B, T: Adapter where T.Model == B, T.Data == MessagePackValue, T.Error == NSError>(lens: Lens<A, [B]>)(adapter: T, @autoclosure(escaping) model: () -> B) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(lift(adapter, model)) >>> MessagePackValueTransformers.array)
}

func messagePackArray<A, B, T: Adapter where T.Model == B, T.Data == MessagePackValue, T.Error == NSError>(lens: Lens<A, [B]?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .Nil)(adapter: T, @autoclosure(escaping) model: () -> B) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(lift(lift(adapter, model)) >>> MessagePackValueTransformers.array, defaultTransformedValue))
}

func messagePackMap<A, B, T: Adapter where T.Model == B, T.Data == MessagePackValue, T.Error == NSError>(lens: Lens<A, B>)(adapter: T, @autoclosure(escaping) model: () -> B) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(adapter, model))
}

func messagePackMap<A, B, T: Adapter where T.Model == B, T.Data == MessagePackValue, T.Error == NSError>(lens: Lens<A, B?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = .Nil)(adapter: T, @autoclosure(escaping) model: () -> B) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(lift(adapter, model), defaultTransformedValue))
}

func messagePackExtended<A, B, T: Adapter where T.Model == B, T.Data == NSData, T.Error == NSError>(lens: Lens<A, B>)(adapter: T, @autoclosure(escaping) model: () -> B, type: Int8) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(transform(lens, lift(adapter, model)), MessagePackValueTransformers.extended(type))
}

func messagePackExtended<A, B, T: Adapter where T.Model == B, T.Data == NSData, T.Error == NSError>(lens: Lens<A, B?>, @autoclosure(escaping) defaultTransformedValue: () -> NSData = NSData())(adapter: T, @autoclosure(escaping) model: () -> B, type: Int8) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(transform(lens, lift(lift(adapter, model), defaultTransformedValue)), MessagePackValueTransformers.extended(type))
}
