import Lustre

public protocol _GroupType: RecordType {
    typealias PersonState
    typealias SourceState
}

public protocol GroupType: _GroupType {
    func source<S: _SourceType where S.State == SourceState>() -> S

    func allMembers<P: _PersonType where P.State == PersonState>() -> [P]

    func allMembers<P: _PersonType where P.State == PersonState>(sortOrdering: SortOrdering) -> [P]

    func add<P: _PersonType where P.State == PersonState>(member: P) -> VoidResult

    func remove<P: _PersonType where P.State == PersonState>(member: P) -> VoidResult
}
