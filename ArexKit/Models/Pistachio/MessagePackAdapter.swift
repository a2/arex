import MessagePack
import Pistachio
import Result
import ValueTransformer

private let dictionaryTransformer: ReversibleValueTransformer<[String : MessagePackValue], MessagePackValue, ErrorType> = {
    let transformClosure: [String : MessagePackValue] -> Result<MessagePackValue, ErrorType> = { dictionary in
        var messagePackDict = [MessagePackValue : MessagePackValue]()
        for (key, value) in dictionary {
            messagePackDict[.String(key)] = value
        }

        return MessagePackValueTransformers.map.transform(messagePackDict)
    }

    let reverseTransformClosure: MessagePackValue -> Result<[String : MessagePackValue], ErrorType> = { value in
        return MessagePackValueTransformers.map.reverseTransform(value).flatMap { dictionary in
            var stringDict = [String : MessagePackValue]()
            for (key, value) in dictionary {
                if let string = key.stringValue {
                    stringDict[string] = value
                } else {
                    return .failure(MessagePackValueTransformersError.ExpectedStringKey)
                }
            }

            return .success(stringDict)
        }
    }

    return ReversibleValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
}()

public struct MessagePackAdapter<Value>: AdapterType {
    private typealias Adapter = DictionaryAdapter<String, Value, MessagePackValue, ErrorType>
    private let adapter: Adapter

    public init(specification: Adapter.Specification, valueClosure: MessagePackValue -> Result<Value, ErrorType>) {
        adapter = DictionaryAdapter(specification: specification, dictionaryTransformer: dictionaryTransformer, valueClosure: valueClosure)
    }

    public init(specification: Adapter.Specification, @autoclosure(escaping) value: () -> Value) {
        self.init(specification: specification, valueClosure: { _ in
            return Result.Success(value())
        })
    }

    public func transform(value: Value) -> Result<MessagePackValue, ErrorType> {
        return adapter.transform(value)
    }

    public func reverseTransform(transformedValue: MessagePackValue) -> Result<Value, ErrorType> {
        return adapter.reverseTransform(transformedValue)
    }
}
