import Foundation
import MessagePack
import Monocle
import Pistachio
import Result
import ValueTransformer

public struct MessagePackValueTransformers {
    public enum Error: Int, ErrorRepresentable {
        public static let domain = "MessagePackValueTransformersError"

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

        public var code: Int {
            return rawValue
        }

        public var description: String {
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

        public var failureReason: String? {
            return nil
        }
    }

    public static let bool: ReversibleValueTransformer<Bool, MessagePackValue, NSError> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Bool(value))
    }, reverseTransformClosure: { value in
        if let value = value.boolValue {
            return .success(value)
        } else {
            return .failure(error(code: Error.InvalidBool))
        }
    })

    public static func int<S: SignedIntegerType>() -> ReversibleValueTransformer<S, MessagePackValue, NSError> {
        return ReversibleValueTransformer(transformClosure: { value in
            return .success(.Int(numericCast(value)))
        }, reverseTransformClosure: { value in
            if let value = value.integerValue {
                return .success(numericCast(value))
            } else {
                return .failure(error(code: Error.InvalidInt))
            }
        })
    }

    public static func uint<U: UnsignedIntegerType>() -> ReversibleValueTransformer<U, MessagePackValue, NSError> {
        return ReversibleValueTransformer(transformClosure: { value in
            return .success(.UInt(numericCast(value)))
        }, reverseTransformClosure: { value in
            if let value = value.unsignedIntegerValue {
                return .success(numericCast(value))
            } else {
                return .failure(error(code: Error.InvalidUInt))
            }
        })
    }

    public static let float: ReversibleValueTransformer<Float32, MessagePackValue, NSError> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Float(value))
    }, reverseTransformClosure: { value in
        if let value = value.floatValue {
            return .success(value)
        } else {
            return .failure(error(code: Error.InvalidFloat))
        }
    })

    public static let double: ReversibleValueTransformer<Float64, MessagePackValue, NSError> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Double(value))
    }, reverseTransformClosure: { value in
        if let value = value.doubleValue {
            return .success(value)
        } else {
            return .failure(error(code: Error.InvalidDouble))
        }
    })

    public static let string: ReversibleValueTransformer<String, MessagePackValue, NSError> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.String(value))
    }, reverseTransformClosure: { value in
        if let value = value.stringValue {
            return .success(value)
        } else {
            return .failure(error(code: Error.InvalidString))
        }
    })

    public static let binary: ReversibleValueTransformer<NSData, MessagePackValue, NSError> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Binary(value))
    }, reverseTransformClosure: { value in
        if let value = value.dataValue {
            return .success(value)
        } else {
            return .failure(error(code: Error.InvalidBinary))
        }
    })

    public static let array: ReversibleValueTransformer<[MessagePackValue], MessagePackValue, NSError> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Array(value))
    }, reverseTransformClosure: { value in
        if let value = value.arrayValue {
            return .success(value)
        } else {
            return .failure(error(code: Error.InvalidArray))
        }
    })

    public static let map: ReversibleValueTransformer<[MessagePackValue : MessagePackValue], MessagePackValue, NSError> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Map(value))
    }, reverseTransformClosure: { value in
        if let value = value.dictionaryValue {
            return .success(value)
        } else {
            return .failure(error(code: Error.InvalidMap))
        }
    })

    public static func extended(type: Int8) -> ReversibleValueTransformer<NSData, MessagePackValue, NSError> {
        return ReversibleValueTransformer(transformClosure: { value in
            return .success(.Extended(type: type, data: value))
        }, reverseTransformClosure: { value in
            if let (decodedType, data) = value.extendedValue {
                if decodedType == type {
                    return .success(data)
                } else {
                    return .failure(error(code: Error.IncorrectExtendedType))
                }
            } else {
                return .failure(error(code: Error.InvalidExtended))
            }
        })
    }
}

public func messagePackBool<A>(lens: Lens<A, Bool>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, MessagePackValueTransformers.bool)
}

public func messagePackBool<A>(lens: Lens<A, Bool?>, defaultTransformedValue: MessagePackValue = .Bool(false)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(MessagePackValueTransformers.bool, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackInt<A, S: SignedIntegerType>(lens: Lens<A, S>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, MessagePackValueTransformers.int())
}

public func messagePackInt<A, S: SignedIntegerType>(lens: Lens<A, S?>, defaultTransformedValue: MessagePackValue = .Int(0)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(MessagePackValueTransformers.int(), defaultTransformedValue: defaultTransformedValue))
}

public func messagePackUInt<A, U: UnsignedIntegerType>(lens: Lens<A, U>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, MessagePackValueTransformers.uint())
}

public func messagePackUInt<A, U: UnsignedIntegerType>(lens: Lens<A, U?>, defaultTransformedValue: MessagePackValue = .UInt(0)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(MessagePackValueTransformers.uint(), defaultTransformedValue: defaultTransformedValue))
}

public func messagePackFloat<A>(lens: Lens<A, Float32>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, MessagePackValueTransformers.float)
}

public func messagePackFloat<A>(lens: Lens<A, Float32?>, defaultTransformedValue: MessagePackValue = .Float(0)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(MessagePackValueTransformers.float, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackDouble<A>(lens: Lens<A, Float64>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, MessagePackValueTransformers.double)
}

public func messagePackDouble<A>(lens: Lens<A, Float64?>, defaultTransformedValue: MessagePackValue = .Double(0)) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(MessagePackValueTransformers.double, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackString<A>(lens: Lens<A, String>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, MessagePackValueTransformers.string)
}

public func messagePackString<A>(lens: Lens<A, String?>, defaultTransformedValue: MessagePackValue = .String("")) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(MessagePackValueTransformers.string, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackBinary<A>(lens: Lens<A, NSData>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, MessagePackValueTransformers.binary)
}

public func messagePackBinary<A>(lens: Lens<A, NSData?>, defaultTransformedValue: MessagePackValue = .Binary(NSData())) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(MessagePackValueTransformers.binary, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackArray<A, T: AdapterType where T.TransformedValueType == MessagePackValue, T.ErrorType == NSError>(lens: Lens<A, [T.ValueType]>)(adapter: T) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(adapter) >>> MessagePackValueTransformers.array)
}

public func messagePackArray<A, T: AdapterType where T.TransformedValueType == MessagePackValue, T.ErrorType == NSError>(lens: Lens<A, [T.ValueType]?>, defaultTransformedValue: MessagePackValue = .Nil)(adapter: T) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(lift(adapter) >>> MessagePackValueTransformers.array, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackMap<A, T: AdapterType where T.TransformedValueType == MessagePackValue, T.ErrorType == NSError>(lens: Lens<A, T.ValueType>)(adapter: T) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, adapter)
}

public func messagePackMap<A, T: AdapterType where T.TransformedValueType == MessagePackValue, T.ErrorType == NSError>(lens: Lens<A, T.ValueType?>, defaultTransformedValue: MessagePackValue = .Nil)(adapter: T) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(lens, lift(adapter, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackExtended<A, T: AdapterType where T.TransformedValueType == NSData, T.ErrorType == NSError>(lens: Lens<A, T.ValueType>)(adapter: T, type: Int8) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(map(lens, adapter), MessagePackValueTransformers.extended(type))
}

public func messagePackExtended<A, T: AdapterType where T.TransformedValueType == NSData, T.ErrorType == NSError>(lens: Lens<A, T.ValueType?>, defaultTransformedValue: NSData = NSData())(adapter: T, type: Int8) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return map(map(lens, lift(adapter, defaultTransformedValue: defaultTransformedValue)), MessagePackValueTransformers.extended(type))
}
