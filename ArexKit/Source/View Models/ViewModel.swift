import ReactiveCocoa

public class ViewModel {
    /// The default throttle interval is 1 second.
    public static let ThrottleInterval: NSTimeInterval = 1.0

    /// The underlying storage of the `active` property.
    private let _active = MutableProperty(false)

    /**
        Whether the view model is currently "active."

        This generally implies that the associated view is visible. When set to `false`,
        the view model should throttle or cancel low-priority or UI-related work.

        This property defaults to `false`.
    */
    public final var active: Bool {
        get {
            return _active.value
        }
        set {
            _active.value = newValue
        }
    }

    /**
        Observes the receiver's `active` property, and sends the receiver whenever it
        changes from `false` to `true`.

        If the receiver is currently active, this signal will send once immediately
        upon subscription.
    */
    public final lazy var didBecomeActiveSignal: Signal<ViewModel, NoError> = {
        let (signal, observer) = Signal<ViewModel, NoError>.pipe()

        self._active.producer.startWithSignal { [unowned self] (signal, signalDisposable) in
            let disposable = signal
                |> filter(boolValue)
                |> map(replace(self))
                |> observe(observer)
            self.disposable.addDisposable(disposable)
            self.disposable.addDisposable(signalDisposable)
        }

        return signal
    }()

    /**
        Observes the receiver's `active` property, and sends the receiver whenever it
        changes from YES to NO.

        If the receiver is currently inactive, this signal will send once immediately
        upon subscription.
    */
    public final lazy var didBecomeInactiveSignal: Signal<ViewModel, NoError> = {
        let (signal, observer) = Signal<ViewModel, NoError>.pipe()

        self._active.producer.startWithSignal { [unowned self] (signal, signalDisposable) in
            let disposable = signal
                |> map(not)
                |> filter(boolValue)
                |> map(replace(self))
                |> observe(observer)
            self.disposable.addDisposable(disposable)
            self.disposable.addDisposable(signalDisposable)
        }

        return signal
    }()

    /// A composite disposable that disposes subscriptions to either `didBecome(Active|Inactive)Signal`.
    private let disposable = CompositeDisposable()

    public init() {

    }

    deinit {
        disposable.dispose()
    }

    /**
        Subscribes (or resubscribes) to the given signal whenever `didBecomeActiveSignal` fires.
        When `didBecomeInactiveSignal` fires, any active subscription to `signal` is disposed.

        :param: producer A signal producer to forward.

        :returns: A signal which forwards `.Next` events from the latest subscription to `producer`, and completes when the receiver is deallocated. If `produer` sends an error at any point, the returned signal will error out as well.
    */
    public final func forwardWhileActive<T, E>(producer: SignalProducer<T, E>) -> SignalProducer<T, E> {
        return SignalProducer { (observer, compositeDisposable) in
            var signalDisposable: Disposable? = nil
            var signalDisposableHandle: CompositeDisposable.DisposableHandle? = nil

            let disposable = self._active.producer.start(
                next: { active in
                    if active {
                        signalDisposable = producer.start(next: { value in
                            sendNext(observer, value)
                        }, error: { error in
                            sendError(observer, error)
                        }, interrupted: {
                            sendInterrupted(observer)
                        })

                        compositeDisposable.addDisposable(signalDisposable)
                    } else {
                        signalDisposable?.dispose()
                        signalDisposableHandle?.remove()
                        signalDisposableHandle = nil
                        signalDisposable = nil
                    }
                },
                completed: {
                    sendCompleted(observer)
                }
            )

            compositeDisposable.addDisposable(disposable)
        }
    }

    /**
        Throttles events on the given signal while the receiver is inactive.
        Unlike `forwardSignalWhileActive()`, this method will stay subscribed to `signal` the entire time, except that its events will be throttled when the receiver becomes inactive.

        :param: interval The minimum duration between Events.
        :param: producer A signal producer to throttle.

        :returns: A signal producer which forwards events from `producer` (throttled while the receiver is inactive), and completes when `producer` completes or the receiver is deallocated.
    */
    public final func throttleWhileInactive<T, E>(interval: NSTimeInterval = ViewModel.ThrottleInterval)(producer: SignalProducer<T, E>) -> SignalProducer<T, E> {
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
