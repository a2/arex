import Foundation
import LlamaKit
import MessagePack_swift
import Pistachio
import ReactiveCocoa

public enum MedicationsControllerError: ErrorRepresentable, ErrorType {
    public static let domain = "MedicationsControllerError"

    case CannotSave(name: String, underlying: NSError?)

    public var code: Int {
        switch self {
        case .CannotSave:
            return 1
        }
    }

    public var description: String {
        switch self {
        case .CannotSave(name: let name, underlying: _):
            return String(format: NSLocalizedString("Could not save medication “%@”. ", comment: ""), arguments: [name])
        }
    }

    public var failureReason: String? {
        switch self {
        case .CannotSave(name: _, underlying: let underlying):
            return underlying?.localizedFailureReason ?? underlying?.localizedDescription
        }
    }

    public var nsError: NSError {
        switch self {
        case .CannotSave(name: _, underlying: let underlying):
            return error(code: self, underlying: underlying)
        }
    }
}

public class MedicationsController {
    /// The file extension to use when saving `Medication` values.
    public static let fileExtension = "rx"

    /// The default directory URL is ~/Documents directory.
    public static let defaultDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
    
    /// The directory in which to save `Medication` values.
    public let directoryURL: NSURL

    /// The file manager used to load the contents of `directoryURL`.
    private let fileManager = NSFileManager()

    /// The queue on which `directoryURL` is loaded and its `Medication` contents are unpacked.
    private lazy var queue: dispatch_queue_t = {
        let attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0)
        return dispatch_queue_create("us.pandamonia.Arex.MedicationsController", attr)
    }()

    /**
        :param: directoryURL The URL of the directory in which to load `Medication` values.
    */
    public init(directoryURL: NSURL = MedicationsController.defaultDirectoryURL) {
        self.directoryURL = directoryURL
    }

    /// Returns the array of URLs contained in `directoryURL`. Returns an error upon failure.
    private func directoryURLContents() -> Result<[NSURL], NSError> {
        var error: NSError?
        if let contents = fileManager.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: [], options: .SkipsHiddenFiles, error: &error) as? [NSURL] {
            return success(contents)
        } else if let error = error {
            return failure(error)
        } else {
            return failure()
        }
    }

    /**
        Returns an array of the `Medication` values contained in `directoryURL`.
        If `directoryURL` cannot be loaded, returns the resulting error.
    
        **Note:** An error is not returned if no `Medication` values can be loaded or
        if a file URL in `directoryURL` does not contain a  `Medication` value.
    */
    private func loadMedications() -> Result<[Medication], NSError> {
        return directoryURLContents().map { URLs in
            return URLs.flatMap { fileURL in
                if let pathExtension = fileURL.pathExtension where pathExtension == MedicationsController.fileExtension,
                    let lastPathComponent = fileURL.lastPathComponent, uuid = NSUUID(UUIDString: lastPathComponent.stringByDeletingPathExtension),
                    data = NSData(contentsOfURL: fileURL), messagePackValue = unpack(data) {

                    switch Adapters.medication.decode(Medication(uuid: uuid), from: messagePackValue) {
                    case let .Success(valueBox):
                        return [valueBox.unbox]
                    case let .Failure(errorBox):
                        println("\(__FUNCTION__) Failed to unpack Medication at \(fileURL): \(errorBox.unbox)")
                    }
                }

                return []
            }
        }
    }

    /// Returns a signal producer that watches the contents of `directoryURL` 
    /// and sends an `Array[Medication]` when the directory's contents change.
    public func medications() -> SignalProducer<[Medication], NSError> {
        return SignalProducer(value: directoryURL)
            |> concat(monitorDirectory(directoryURL))
            |> observeOn(QueueScheduler(queue))
            |> mapError { $0.nsError }
            |> tryMap { [unowned self] _ in self.loadMedications() }
            |> observeOn(QueueScheduler.mainQueueScheduler)
    }

    /**
        Saves the specified `Medication` value when the returned signal producer is started.
    
        **NB:** Assigns the `Medication` value a `uuid` if it does not already have one.

        :param: medication The `Medication` to save.
    
        :returns: A signal producer that saves the argument when started.
    */
    public func save(inout #medication: Medication) -> SignalProducer<Void, MedicationsControllerError> {
        let name = get(MedicationLenses.name, medication) ?? undefined("You cannot save a Medication without a name")
        let uuid: NSUUID

        if let _uuid = get(MedicationLenses.uuid, medication) {
            uuid = _uuid
        } else {
            uuid = NSUUID()
            medication = set(MedicationLenses.uuid, medication, uuid)
        }

        let producer = SignalProducer<Void, MedicationsControllerError> { (observer, disposable) in
            switch Adapters.medication.encode(medication) {
            case .Success(let valueBox):
                let data = pack(valueBox.unbox)
                let url = self.directoryURL.URLByAppendingPathComponent("\(uuid.UUIDString).\(MedicationsController.fileExtension)")

                var error: NSError? = nil
                if data.writeToURL(url, options: .DataWritingAtomic, error: &error) {
                    sendCompleted(observer)
                } else {
                    sendError(observer, .CannotSave(name: name, underlying: error))
                }
            case .Failure(let errorBox):
                sendError(observer, .CannotSave(name: name, underlying: errorBox.unbox))
            }
        }

        return producer |> observeOn(QueueScheduler.mainQueueScheduler)
    }
}
