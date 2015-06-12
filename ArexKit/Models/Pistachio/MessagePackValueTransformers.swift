import Foundation
import MessagePack
import Monocle
import Pistachio
import Result
import ValueTransformer

public enum MessagePackValueTransformersError: ErrorType {
    case InvalidType(String)
    case IncorrectExtendedType
    case ExpectedStringKey
}

public struct MessagePackValueTransformers {
    public static let bool: ReversibleValueTransformer<Bool, MessagePackValue, ErrorType> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Bool(value))
    }, reverseTransformClosure: { value in
        if let value = value.boolValue {
            return .success(value)
        } else {
            return .failure(MessagePackValueTransformersError.InvalidType("Bool"))
        }
    })

    public static func int<S: SignedIntegerType>() -> ReversibleValueTransformer<S, MessagePackValue, ErrorType> {
        return ReversibleValueTransformer(transformClosure: { value in
            return .success(.Int(numericCast(value)))
        }, reverseTransformClosure: { value in
            if let value = value.integerValue {
                return .success(numericCast(value))
            } else {
                return .failure(MessagePackValueTransformersError.InvalidType("Int"))
            }
        })
    }

    public static func uint<U: UnsignedIntegerType>() -> ReversibleValueTransformer<U, MessagePackValue, ErrorType> {
        return ReversibleValueTransformer(transformClosure: { value in
            return .success(.UInt(numericCast(value)))
        }, reverseTransformClosure: { value in
            if let value = value.unsignedIntegerValue {
                return .success(numericCast(value))
            } else {
                return .failure(MessagePackValueTransformersError.InvalidType("UInt"))
            }
        })
    }

    public static let float: ReversibleValueTransformer<Float32, MessagePackValue, ErrorType> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Float(value))
    }, reverseTransformClosure: { value in
        if let value = value.floatValue {
            return .success(value)
        } else {
            return .failure(MessagePackValueTransformersError.InvalidType("Float"))
        }
    })

    public static let double: ReversibleValueTransformer<Float64, MessagePackValue, ErrorType> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Double(value))
    }, reverseTransformClosure: { value in
        if let value = value.doubleValue {
            return .success(value)
        } else {
            return .failure(MessagePackValueTransformersError.InvalidType("Double"))
        }
    })

    public static let string: ReversibleValueTransformer<String, MessagePackValue, ErrorType> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.String(value))
    }, reverseTransformClosure: { value in
        if let value = value.stringValue {
            return .success(value)
        } else {
            return .failure(MessagePackValueTransformersError.InvalidType("String"))
        }
    })

    public static let binary: ReversibleValueTransformer<Data, MessagePackValue, ErrorType> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Binary(value))
    }, reverseTransformClosure: { value in
        if let value = value.dataValue {
            return .success(value)
        } else {
            return .failure(MessagePackValueTransformersError.InvalidType("Binary"))
        }
    })

    public static let array: ReversibleValueTransformer<[MessagePackValue], MessagePackValue, ErrorType> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Array(value))
    }, reverseTransformClosure: { value in
        if let value = value.arrayValue {
            return .success(value)
        } else {
            return .failure(MessagePackValueTransformersError.InvalidType("Array"))
        }
    })

    public static let map: ReversibleValueTransformer<[MessagePackValue : MessagePackValue], MessagePackValue, ErrorType> = ReversibleValueTransformer(transformClosure: { value in
        return .success(.Map(value))
    }, reverseTransformClosure: { value in
        if let value = value.dictionaryValue {
            return .success(value)
        } else {
            return .failure(MessagePackValueTransformersError.InvalidType("Map"))
        }
    })

    public static func extended(type: Int8) -> ReversibleValueTransformer<Data, MessagePackValue, ErrorType> {
        return ReversibleValueTransformer(transformClosure: { value in
            return .success(.Extended(type, value))
        }, reverseTransformClosure: { value in
            if let (decodedType, data) = value.extendedValue {
                if decodedType == type {
                    return .success(data)
                } else {
                    return .failure(MessagePackValueTransformersError.IncorrectExtendedType)
                }
            } else {
                return .failure(MessagePackValueTransformersError.InvalidType("Extended"))
            }
        })
    }
}

public func messagePackBool<A>(lens: Lens<A, Bool>) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, MessagePackValueTransformers.bool)
}

public func messagePackBool<A>(lens: Lens<A, Bool?>, defaultTransformedValue: MessagePackValue = .Bool(false)) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, lift(MessagePackValueTransformers.bool, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackInt<A, S: SignedIntegerType>(lens: Lens<A, S>) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, MessagePackValueTransformers.int())
}

public func messagePackInt<A, S: SignedIntegerType>(lens: Lens<A, S?>, defaultTransformedValue: MessagePackValue = .Int(0)) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, lift(MessagePackValueTransformers.int(), defaultTransformedValue: defaultTransformedValue))
}

public func messagePackUInt<A, U: UnsignedIntegerType>(lens: Lens<A, U>) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, MessagePackValueTransformers.uint())
}

public func messagePackUInt<A, U: UnsignedIntegerType>(lens: Lens<A, U?>, defaultTransformedValue: MessagePackValue = .UInt(0)) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, lift(MessagePackValueTransformers.uint(), defaultTransformedValue: defaultTransformedValue))
}

public func messagePackFloat<A>(lens: Lens<A, Float32>) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, MessagePackValueTransformers.float)
}

public func messagePackFloat<A>(lens: Lens<A, Float32?>, defaultTransformedValue: MessagePackValue = .Float(0)) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, lift(MessagePackValueTransformers.float, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackDouble<A>(lens: Lens<A, Float64>) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, MessagePackValueTransformers.double)
}

public func messagePackDouble<A>(lens: Lens<A, Float64?>, defaultTransformedValue: MessagePackValue = .Double(0)) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, lift(MessagePackValueTransformers.double, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackString<A>(lens: Lens<A, String>) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, MessagePackValueTransformers.string)
}

public func messagePackString<A>(lens: Lens<A, String?>, defaultTransformedValue: MessagePackValue = .String("")) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, lift(MessagePackValueTransformers.string, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackBinary<A>(lens: Lens<A, Data>) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, MessagePackValueTransformers.binary)
}

public func messagePackBinary<A>(lens: Lens<A, Data?>, defaultTransformedValue: MessagePackValue = .Binary([])) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return map(lens, lift(MessagePackValueTransformers.binary, defaultTransformedValue: defaultTransformedValue))
}

public func messagePackArray<A, T: AdapterType where T.TransformedValueType == MessagePackValue, T.ErrorType == ErrorType>(lens: Lens<A, [T.ValueType]>) -> (adapter: T) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return { adapter in
        return map(lens, lift(adapter) >>> MessagePackValueTransformers.array)
    }
}

public func messagePackArray<A, T: AdapterType where T.TransformedValueType == MessagePackValue, T.ErrorType == ErrorType>(lens: Lens<A, [T.ValueType]?>, defaultTransformedValue: MessagePackValue = .Nil) -> (adapter: T) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return { adapter in
        return map(lens, lift(lift(adapter) >>> MessagePackValueTransformers.array, defaultTransformedValue: defaultTransformedValue))
    }
}

public func messagePackMap<A, T: AdapterType where T.TransformedValueType == MessagePackValue, T.ErrorType == ErrorType>(lens: Lens<A, T.ValueType>) -> (adapter: T) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return { adapter in
        return map(lens, adapter)
    }
}

public func messagePackMap<A, T: AdapterType where T.TransformedValueType == MessagePackValue, T.ErrorType == ErrorType>(lens: Lens<A, T.ValueType?>, defaultTransformedValue: MessagePackValue = .Nil) -> (adapter: T) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return { adapter in
        return map(lens, lift(adapter, defaultTransformedValue: defaultTransformedValue))
    }
}

public func messagePackExtended<A, T: AdapterType where T.TransformedValueType == Data, T.ErrorType == ErrorType>(lens: Lens<A, T.ValueType>) -> (adapter: T, type: Int8) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return { adapter, type in
        return map(map(lens, adapter), MessagePackValueTransformers.extended(type))
    }
}

public func messagePackExtended<A, T: AdapterType where T.TransformedValueType == Data, T.ErrorType == ErrorType>(lens: Lens<A, T.ValueType?>, defaultTransformedValue: Data = Data()) -> (adapter: T, type: Int8) -> Lens<Result<A, ErrorType>, Result<MessagePackValue, ErrorType>> {
    return { adapter, type in
        return map(map(lens, lift(adapter, defaultTransformedValue: defaultTransformedValue)), MessagePackValueTransformers.extended(type))
    }
}
