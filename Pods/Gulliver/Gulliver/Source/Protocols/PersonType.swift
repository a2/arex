import Lustre

public protocol _PersonType: RecordType {
    typealias GroupState
    typealias SourceState
}

public protocol PersonType: _PersonType {

    var hasImageData: Bool { get }

    func imageData() -> NSData?

    func imageData(format: ImageFormat) -> NSData?

    func setImageData(imageData: NSData?) -> VoidResult

    static var sortOrdering: SortOrdering { get }

    func source<S: _SourceType where S.State == SourceState>() -> S

    func linkedPeople<P: _PersonType where P.State == State>() -> [P]

    var compositeNameFormat: CompositeNameFormat { get }

    var compositeNameDelimiter: String { get }

    static func vCardRepresentation<P: _PersonType where P.State == State>(people: [P]) -> NSData

    static func compare<P1: _PersonType, P2: _PersonType where P1.State == State, P2.State == State>(person1: P1, person2: P2, ordering: SortOrdering) -> NSComparisonResult

    static func people<P: _PersonType, S: _SourceType where P.State == State, S.State == SourceState>(vCardRepresentation: NSData, source: S?) -> [P]?
}
