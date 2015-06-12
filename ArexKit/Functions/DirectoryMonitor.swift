import Foundation
import ReactiveCocoa

/// The queue on which the internal `dispatch_source_t` in `monitorDirectory()` invokes its event handler.
private let queue = dispatch_queue_create("us.pandamonia.Arex.MonitorDirectory", DISPATCH_QUEUE_CONCURRENT)

public enum MonitorDirectoryError: Swift.ErrorType {
    case CannotOpenDirectory(Int32)
    case CannotMonitorDirectory
}

extension MonitorDirectoryError: ReactiveCocoa.ErrorType {
    public var nsError: NSError {
        return self as NSError
    }
}

/// Monitors the specified directory for file system changes.
///
/// - parameter directoryURL: The file URL of the directory to monitor.
///
/// - returns: A `SignalProducer` that, when started, sends the directory URL whenever a change occurs.
public func monitorDirectory(directoryURL: NSURL) -> SignalProducer<NSURL, MonitorDirectoryError> {
    return SignalProducer { (observer, disposable) in
        let fileDescriptor = open(directoryURL.fileSystemRepresentation, O_EVTONLY)
        if fileDescriptor < 0 {
            return sendError(observer, .CannotOpenDirectory(errno))
        }

        var source: dispatch_queue_t? = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(fileDescriptor), DISPATCH_VNODE_WRITE, queue)
        if source == nil {
            sendError(observer, .CannotMonitorDirectory)
            return
        }

        disposable += ActionDisposable {
            source.map(dispatch_source_cancel)
        }

        dispatch_source_set_event_handler(source!) {
            sendNext(observer, directoryURL)
        }

        dispatch_source_set_cancel_handler(source!) {
            close(fileDescriptor)
            source = nil
        }

        dispatch_resume(source!)
    }
}
