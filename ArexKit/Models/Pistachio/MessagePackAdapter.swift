import MessagePack
import Pistachio
import Result
import ValueTransformer

private let stringKeyedMap: ReversibleValueTransformer<[String : MessagePackValue], MessagePackValue, NSError> = {
    let transformClosure: [String : MessagePackValue] -> Result<MessagePackValue, NSError> = { dictionary in
        var messagePackDict = [MessagePackValue : MessagePackValue]()
        for (key, value) in dictionary {
            messagePackDict[.String(key)] = value
        }

        return MessagePackValueTransformers.map.transform(messagePackDict)
    }

    let reverseTransformClosure: MessagePackValue -> Result<[String : MessagePackValue], NSError> = { value in
        return MessagePackValueTransformers.map.reverseTransform(value).flatMap { dictionary in
            var stringDict = [String : MessagePackValue]()
            for (key, value) in dictionary {
                if let string = key.stringValue {
                    stringDict[string] = value
                } else {
                    return .failure(Result<[String : MessagePackValue], NSError>.error())
                }
            }

            return .success(stringDict)
        }
    }

    return ReversibleValueTransformer(transformClosure: transformClosure, reverseTransformClosure: reverseTransformClosure)
}()

public struct MessagePackAdapter<Value>: AdapterType {
    private typealias Adapter = DictionaryAdapter<String, Value, MessagePackValue, NSError>
    private let adapter: Adapter


    public init(specification: Adapter.Specification, valueClosure: MessagePackValue -> Result<Value, NSError>) {
        adapter = DictionaryAdapter(specification: specification, dictionaryTransformer: stringKeyedMap, valueClosure: valueClosure)
    }

    public init(specification: Adapter.Specification, @autoclosure(escaping) value: () -> Value) {
        self.init(specification: specification, valueClosure: { _ in
            return Result.success(value())
        })
    }

    public func transform(value: Value) -> Result<MessagePackValue, NSError> {
        return adapter.transform(value)
    }

    public func reverseTransform(transformedValue: MessagePackValue) -> Result<Value, NSError> {
        return adapter.reverseTransform(transformedValue)
    }
}
