import AddressBook
import Lustre

public protocol StateRepresentable {
    typealias State
    init(state: State)
    var state: State { get }
}

public typealias ExternalChangeHandler = GLVExternalChangeHandler
public protocol ExternalChangeObserver {
    mutating func stopObserving()
}

public protocol AddressBookType: StateRepresentable {
    typealias RecordState
    typealias PersonState
    typealias GroupState
    typealias SourceState

    static var authorizationStatus: AuthorizationStatus { get }

    func requestAccess(completion: VoidResult -> Void)

    var hasUnsavedChanges: Bool { get }

    func save() -> VoidResult

    func observeExternalChanges(callback: ExternalChangeHandler) -> ExternalChangeObserver

    func addRecord<R: _RecordType where R.State == RecordState>(record: R) -> VoidResult

    func removeRecord<R: _RecordType where R.State == RecordState>(record: R) -> VoidResult

    // MARK: - People

    var personCount: Int { get }

    func person<P: _PersonType where P.State == PersonState>(recordID: RecordID) -> P?

    func people<P: _PersonType where P.State == PersonState>(name: String) -> [P]

    func allPeople<P: _PersonType, S: _SourceType where P.State == PersonState, S.State == SourceState>(source: S) -> [P]

    func allPeople<P: _PersonType, S: _SourceType where P.State == PersonState, S.State == SourceState>(source: S, sortOrdering: SortOrdering) -> [P]

    // MARK: - Groups

    var groupCount: Int { get }

    func group<G: _GroupType where G.State == GroupState>(recordID: RecordID) -> G?

    func allGroups<G: _GroupType where G.State == GroupState>() -> [G]

    func allGroups<G: _GroupType, S: _SourceType where G.State == GroupState, S.State == SourceState>(source: S) -> [G]

    // MARK: - Sources

    func defaultSource<S: _SourceType where S.State == SourceState>() -> S

    func source<S: _SourceType where S.State == SourceState>(recordID: RecordID) -> S?

    func allSources<S: _SourceType where S.State == SourceState>() -> [S]
}
