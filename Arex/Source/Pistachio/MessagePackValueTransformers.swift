import Foundation
import LlamaKit
import MessagePack
import Pistachio

struct MessagePackValueTransformers {
    enum Error: Int {
        static let Domain = "MessagePackValueTransformers"
        case InvalidInput = 1
    }

    static let bool: ValueTransformer<Bool, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Bool(value))
    }, reverseTransformClosure: { value in
        if let value = value.boolValue {
            return success(value)
        } else {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Bool from MessagePack", comment: ""),
                NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack bool, got: %@.", comment: ""), value.description)
            ]
            return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
        }
    })

    static func int<S: SignedIntegerType>() -> ValueTransformer<S, MessagePackValue, NSError> {
        return ValueTransformer(transformClosure: { value in
            return success(.Int(numericCast(value)))
        }, reverseTransformClosure: { value in
            if let value = value.integerValue {
                return success(numericCast(value))
            } else {
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Int from MessagePack", comment: ""),
                    NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack int, got: %@.", comment: ""), value.description)
                ]
                return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
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
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Could not decode UInt from MessagePack", comment: ""),
                    NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack uint, got: %@.", comment: ""), value.description)
                ]
                return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
            }
        })
    }

    static let float: ValueTransformer<Float32, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Float(value))
    }, reverseTransformClosure: { value in
        if let value = value.floatValue {
            return success(value)
        } else {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Float from MessagePack", comment: ""),
                NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack float, got: %@.", comment: ""), value.description)
            ]
            return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
        }
    })

    static let double: ValueTransformer<Float64, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Double(value))
    }, reverseTransformClosure: { value in
        if let value = value.doubleValue {
            return success(value)
        } else {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Double from MessagePack", comment: ""),
                NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack double, got: %@.", comment: ""), value.description)
            ]
            return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
        }
    })

    static let string: ValueTransformer<String, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.String(value))
    }, reverseTransformClosure: { value in
        if let value = value.stringValue {
            return success(value)
        } else {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not decode String from MessagePack", comment: ""),
                NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack string, got: %@.", comment: ""), value.description)
            ]
            return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
        }
    })

    static let binary: ValueTransformer<NSData, MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Binary(value))
    }, reverseTransformClosure: { value in
        if let value = value.dataValue {
            return success(value)
        } else {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Binary from MessagePack", comment: ""),
                NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack binary, got: %@.", comment: ""), value.description)
            ]
            return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
        }
    })

    static let array: ValueTransformer<[MessagePackValue], MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Array(value))
    }, reverseTransformClosure: { value in
        if let value = value.arrayValue {
            return success(value)
        } else {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Array from MessagePack", comment: ""),
                NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack array, got: %@.", comment: ""), value.description)
            ]
            return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
        }
    })

    static let map: ValueTransformer<[MessagePackValue : MessagePackValue], MessagePackValue, NSError> = ValueTransformer(transformClosure: { value in
        return success(.Map(value))
    }, reverseTransformClosure: { value in
        if let value = value.dictionaryValue {
            return success(value)
        } else {
            let userInfo = [
                NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Map from MessagePack", comment: ""),
                NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack map, got: %@.", comment: ""), value.description)
            ]
            return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
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
                    let userInfo = [
                        NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Extended from MessagePack", comment: ""),
                        NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack extended type %@, got: %@.", comment: ""), type.description, decodedType.description)
                    ]
                    return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
                }
            } else {
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Could not decode Extended from MessagePack", comment: ""),
                    NSLocalizedFailureReasonErrorKey: String(format: NSLocalizedString("Expected a MessagePack extended, got: %@.", comment: ""), value.description)
                ]
                return failure(NSError(domain: Error.Domain, code: Error.InvalidInput.rawValue, userInfo: userInfo))
            }
        })
    }
}

func messagePackBool<A>(lens: Lens<A, Bool>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.bool)
}

func messagePackBool<A>(lens: Lens<A, Bool?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = false) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.bool, defaultTransformedValue))
}

func messagePackInt<A, S: SignedIntegerType>(lens: Lens<A, S>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.int())
}

func messagePackInt<A, S: SignedIntegerType>(lens: Lens<A, S?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = 0) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.int(), 0))
}

func messagePackUInt<A, U: UnsignedIntegerType>(lens: Lens<A, U>) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, MessagePackValueTransformers.uint())
}

func messagePackUInt<A, U: UnsignedIntegerType>(lens: Lens<A, U?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = 0) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(MessagePackValueTransformers.uint(), 0))
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

func messagePackString<A>(lens: Lens<A, String?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = "") -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
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

func messagePackArray<A, B, T: Adapter where T.Model == B, T.Data == MessagePackValue, T.Error == NSError>(lens: Lens<A, [B]?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = nil)(adapter: T, @autoclosure(escaping) model: () -> B) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(lift(lift(adapter, model)) >>> MessagePackValueTransformers.array, defaultTransformedValue))
}

func messagePackMap<A, B, T: Adapter where T.Model == B, T.Data == MessagePackValue, T.Error == NSError>(lens: Lens<A, B>)(adapter: T, @autoclosure(escaping) model: () -> B) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(adapter, model))
}

func messagePackMap<A, B, T: Adapter where T.Model == B, T.Data == MessagePackValue, T.Error == NSError>(lens: Lens<A, B?>, @autoclosure(escaping) defaultTransformedValue: () -> MessagePackValue = nil)(adapter: T, @autoclosure(escaping) model: () -> B) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(lens, lift(lift(adapter, model), defaultTransformedValue))
}

func messagePackExtended<A, B, T: Adapter where T.Model == B, T.Data == NSData, T.Error == NSError>(lens: Lens<A, B>)(adapter: T, @autoclosure(escaping) model: () -> B, type: Int8) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(transform(lens, lift(adapter, model)), MessagePackValueTransformers.extended(type))
}

func messagePackExtended<A, B, T: Adapter where T.Model == B, T.Data == NSData, T.Error == NSError>(lens: Lens<A, B?>, @autoclosure(escaping) defaultTransformedValue: () -> NSData = NSData())(adapter: T, @autoclosure(escaping) model: () -> B, type: Int8) -> Lens<Result<A, NSError>, Result<MessagePackValue, NSError>> {
    return transform(transform(lens, lift(lift(adapter, model), defaultTransformedValue)), MessagePackValueTransformers.extended(type))
}
