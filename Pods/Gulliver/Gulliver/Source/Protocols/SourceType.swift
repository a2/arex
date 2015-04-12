public protocol _SourceType: RecordType {
    typealias PersonState
    typealias GroupState
}

public protocol SourceType: _SourceType {
    var sourceKind: SourceKind { get }

    func newPerson<P: _PersonType where P.State == PersonState>() -> P
    
    func newGroup<G: _GroupType where G.State == GroupState>() -> G
}
