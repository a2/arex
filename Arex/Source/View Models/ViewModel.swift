import ReactiveCocoa

class ViewModel {
    private static let throttleInterval: NSTimeInterval = 1

    private let _active = MutableProperty(false)
    final var active: Bool {
        get {
            return _active.value
        }
        set {
            _active.value = newValue
        }
    }

    final let didBecomeActiveSignal: Signal<ViewModel, NoError>
    private let didBecomeActiveSignalObserver: SinkOf<Event<ViewModel, NoError>>

    final let didBecomeInactiveSignal: Signal<ViewModel, NoError>
    private let didBecomeInactiveSignalObserver: SinkOf<Event<ViewModel, NoError>>

    private let disposable = CompositeDisposable()

    init() {
        (self.didBecomeActiveSignal, self.didBecomeActiveSignalObserver) = Signal.pipe()
        (self.didBecomeInactiveSignal, self.didBecomeInactiveSignalObserver) = Signal.pipe()

        self._active.producer.startWithSignal { [unowned self] (signal, disposable) in
            signal
                |> filter(boolValue)
                |> map(replace(self))
                |> observe(self.didBecomeActiveSignalObserver)

            signal
                |> map(not)
                |> filter(boolValue)
                |> map(replace(self))
                |> observe(self.didBecomeInactiveSignalObserver)

            self.disposable.addDisposable(disposable)
        }
    }

    final func forwardWhileActive<T, E>(producer: SignalProducer<T, E>) -> SignalProducer<T, E> {
        return _active.producer
            |> concat(SignalProducer(value: false))
            |> promoteErrors(E)
            |> joinMap(.Latest) { value in
                if value {
                    return producer
                } else {
                    return .empty
                }
            }
    }

    final func throttleWhileInactive<T, E>(interval: NSTimeInterval = ViewModel.throttleInterval)(producer: SignalProducer<T, E>) -> SignalProducer<T, E> {
        return _active.producer
            |> promoteErrors(E)
            |> materialize
            |> combineLatestWith(producer |> materialize)
            |> joinMap(.Latest) { (activeEvent: Event<Bool, E>, signalEvent: Event<T, E>) -> SignalProducer<Event<T, E>, NoError> in
                if activeEvent.isTerminating {
                    return SignalProducer(value: activeEvent.map { bool in
                        // `bool` is not `T` but this closure should never be called because `activeEvent.isTterminating`
                        // A `fatalError` should go here but it messes with the type checker.
                        return bool as! T
                    })
                }

                if signalEvent.isTerminating {
                    return SignalProducer(value: signalEvent)
                }

                switch activeEvent {
                case let .Next(valueBox):
                    var signalProducer = SignalProducer<Event<T, E>, NoError>(value: signalEvent)
                    if !valueBox.unbox.boolValue {
                        signalProducer = signalProducer |> delay(interval, onScheduler: QueueScheduler())
                    }
                    return signalProducer
                default:
                    fatalError("All non-Event.Next cases handled above")
                }
            }
            |> dematerialize
    }
}
