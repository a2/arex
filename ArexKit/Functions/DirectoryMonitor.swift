import Foundation
import ReactiveCocoa

/// The queue on which the internal `dispatch_source_t` in `monitorDirectory()` invokes its event handler.
private let queue = dispatch_queue_create("us.pandamonia.Arex.MonitorDirectory", DISPATCH_QUEUE_CONCURRENT)

public enum MonitorDirectoryError: Swift.ErrorType, ErrorRepresentable, ReactiveCocoa.ErrorType {
    public static let domain = "MonitorDirectoryError"

    case CannotOpenDirectory(Int32)
    case CannotMonitorDirectory

    public var code: Int {
        switch self {
        case .CannotOpenDirectory(_):
            return 1
        case .CannotMonitorDirectory:
            return 2
        }
    }

    public var description: String {
        switch self {
        case .CannotOpenDirectory:
            return NSLocalizedString("Unable not open() the directory.", comment: "")
        case .CannotMonitorDirectory:
            return NSLocalizedString("Unable to create source to monitor the directory.", comment: "")
        }
    }

    public var failureReason: String? {
        return nil
    }

    public var nsError: NSError {
        let posixErrno: Int32?
        switch self {
        case .CannotOpenDirectory(let e):
            posixErrno = e
        case .CannotMonitorDirectory:
            posixErrno = nil
        }

        let underlying = posixErrno.map { posixErrno -> NSError in
            var userInfo = [NSObject : AnyObject]()
            if let errorString = String.fromCString(strerror(posixErrno)) {
                userInfo[NSLocalizedDescriptionKey] = errorString
            }
            return NSError(domain: NSPOSIXErrorDomain, code: numericCast(posixErrno), userInfo: userInfo)
        }

        return error(code: self, underlying: underlying)
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
