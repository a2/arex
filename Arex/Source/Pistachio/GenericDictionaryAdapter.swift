import LlamaKit
import Pistachio

struct GenericDictionaryAdapter<Model, Key: Hashable, Data, Error>: Adapter {
    private let specification: [Key : Lens<Result<Model, Error>, Result<Data, Error>>]
    private let dictionaryTansformer: ValueTransformer<[Key : Data], Data, Error>

    init(specification: [Key : Lens<Result<Model, Error>, Result<Data, Error>>], dictionaryTansformer: ValueTransformer<[Key : Data], Data, Error>) {
        self.specification = specification
        self.dictionaryTansformer = dictionaryTansformer
    }

    func encode(model: Model) -> Result<Data, Error> {
        var dictionary = [Key : Data]()
        for (key, lens) in specification {
            switch get(lens, success(model)) {
            case .Success(let value):
                dictionary[key] = value.unbox
            case .Failure(let error):
                return failure(error.unbox)
            }
        }

        return dictionaryTansformer.transformedValue(dictionary)
    }

    func decode(model: Model, from data: Data) -> Result<Model, Error> {
        return dictionaryTansformer.reverseTransformedValue(data).flatMap { dictionary in
            var result: Result<Model, Error> = success(model)
            for (key, lens) in self.specification {
                if let value = dictionary[key] {
                    result = set(lens, result, success(value))
                    if !result.isSuccess { break }
                }
            }

            return result
        }
    }
}
