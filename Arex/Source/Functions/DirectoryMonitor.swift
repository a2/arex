import Foundation
import LlamaKit
import ReactiveCocoa

/// The queue on which the internal `dispatch_source_t` in `monitorDirectory()` invokes its event handler.
private let queue = dispatch_queue_create("us.pandamonia.Arex.MonitorDirectory", DISPATCH_QUEUE_CONCURRENT)

enum MonitorDirectoryError: Int, ErrorRepresentable {
    static let domain = "MonitorDirectoryError"

    case CannotOpenDirectory
    case CannotMonitorDirectory

    var code: Int {
        return rawValue
    }

    var description: String {
        switch self {
        case .CannotOpenDirectory:
            return NSLocalizedString("Unable not open() the directory.", comment: "")
        case .CannotMonitorDirectory:
            return NSLocalizedString("Unable to create source to monitor the directory.", comment: "")
        }
    }

    var failureReason: String? {
        return nil
    }
}

/**
    Monitors the specified directory for file system changes.

    :param: directoryURL The file URL of the directory to monitor.

    :returns: A `SignalProducer` that, when started, sends void values whenever a change occurs in the specified directory.
*/
public func monitorDirectory(directoryURL: NSURL) -> SignalProducer<Void, NSError> {
    return SignalProducer<Void, NSError> { (observer, disposable) in
        let fileDescriptor = open(directoryURL.fileSystemRepresentation, O_EVTONLY)
        if fileDescriptor < 0 {
            let errorCode = errno
            var userInfo = [NSObject : AnyObject]()
            if let errorString = String.fromCString(strerror(errorCode)) {
                userInfo[NSLocalizedDescriptionKey] = errorString
            }
            let underlying = NSError(domain: NSPOSIXErrorDomain, code: Int(errorCode), userInfo: userInfo)
            sendError(observer, error(code: MonitorDirectoryError.CannotOpenDirectory, underlying: underlying))
            return
        }

        var source: dispatch_queue_t? = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(fileDescriptor), DISPATCH_VNODE_WRITE, queue)
        if source == nil {
            sendError(observer, error(code: MonitorDirectoryError.CannotMonitorDirectory))
            return
        }

        disposable.addDisposable {
            if let source = source {
                dispatch_source_cancel(source)
            }
        }

        dispatch_source_set_event_handler(source!) {
            sendNext(observer, ())
        }

        dispatch_source_set_cancel_handler(source!) {
            close(fileDescriptor)
            source = nil
        }

        dispatch_resume(source!)
    }
}
