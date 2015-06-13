import Foundation
import MessagePack
import Monocle
import Pistachio
import Result
import ReactiveCocoa

public enum MedicationsControllerError: Swift.ErrorType {
    case CannotSave(name: String, underlying: Swift.ErrorType?)
}

extension MedicationsControllerError: ReactiveCocoa.ErrorType {
    public var nsError: NSError {
        return self as NSError
    }
}

public class MedicationsController {
    /// The file extension to use when saving `Medication` values.
    public static let fileExtension = "rx"

    /// The default directory URL is ~/Documents directory.
    public static let defaultDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!

    /// The directory in which to save `Medication` values.
    public let directoryURL: NSURL

    /// The file manager used to load the contents of `directoryURL`.
    private let fileManager = NSFileManager()

    /// The queue on which `directoryURL` is loaded and its `Medication` contents are unpacked.
    private lazy var queue: dispatch_queue_t = {
        let attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0)
        return dispatch_queue_create("us.pandamonia.Arex.MedicationsController", attr)
    }()

    /// - parameter directoryURL: The URL of the directory in which to load `Medication` values.
    public init(directoryURL: NSURL = MedicationsController.defaultDirectoryURL) {
        self.directoryURL = directoryURL
    }

    /// Returns the array of URLs contained in `directoryURL`. Returns an error upon failure.
    private func directoryURLContents() -> Result<[NSURL], NSError> {
        do {
            let contents = try fileManager.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: [], options: .SkipsHiddenFiles)
            return .success(contents)
        } catch let error {
            return .failure(error as NSError)
        }
    }

    /// Returns an array of the `Medication` values contained in `directoryURL`.
    /// If `directoryURL` cannot be loaded, returns the resulting error.
    ///
    /// **Note:** An error is not returned if no `Medication` values can be loaded or
    /// if a file URL in `directoryURL` does not contain a  `Medication` value.
    private func loadMedications() -> Result<[Medication], NSError> {
        return directoryURLContents().map { URLs in
            return URLs.flatMap { fileURL in
                let result: Medication?
                if let pathExtension = fileURL.pathExtension where pathExtension == MedicationsController.fileExtension,
                    let lastPathComponent = fileURL.lastPathComponent,
                    UUID = NSUUID(UUIDString: lastPathComponent.stringByDeletingPathExtension),
                    data = NSData(contentsOfURL: fileURL) {
                        do {
                            let messagePackValue = try unpack(data)
                            let medication = Adapters.medication(UUID: UUID).reverseTransform(messagePackValue)

                            result = medication.analysis(ifSuccess: {
                                $0
                            }, ifFailure: {
                                print("\(__FUNCTION__) Failed to unpack Medication at \(fileURL): \($0)")
                                return nil
                            })
                        } catch {
                            result = nil
                        }
                } else {
                    result = nil
                }

                return result
            }
        }
    }

    /// Returns a signal producer that watches the contents of `directoryURL`
    /// and sends an `Array[Medication]` when the directory's contents change.
    public func medications() -> SignalProducer<[Medication], NSError> {
        return SignalProducer(value: directoryURL)
            |> concat(monitorDirectory(directoryURL))
            |> observeOn(QueueScheduler(queue: queue))
            |> mapError { $0.nsError }
            |> attemptMap { [unowned self] _ in self.loadMedications() }
            |> observeOn(QueueScheduler.mainQueueScheduler)
    }

    /// Saves the specified `Medication` value when the returned signal producer is started.
    ///
    /// **NB:** Assigns the `Medication` value a `uuid` if it does not already have one.
    ///
    /// - parameter medication: The `Medication` to save.
    ///
    /// - returns: A signal producer that saves the argument when started.
    public func save(inout medication medication: Medication) -> SignalProducer<Void, MedicationsControllerError> {
        let name = get(MedicationLenses.name, medication) ?? undefined("You cannot save a Medication without a name")
        let uuid = get(MedicationLenses.UUID, medication)

        let producer = SignalProducer<Void, MedicationsControllerError> { (observer, disposable) in
            Adapters.medication().transform(medication).analysis(ifSuccess: {
                let url = self.directoryURL.URLByAppendingPathComponent("\(uuid.UUIDString).\(MedicationsController.fileExtension)")

                var packed = pack($0)
                let data = NSData(bytes: &packed, length: packed.count)

                do {
                    try data.writeToURL(url, options: .DataWritingAtomic)

                    if !get(MedicationLenses.isPersisted, medication) {
                        set(MedicationLenses.isPersisted, medication, true)
                    }

                    sendCompleted(observer)
                } catch let error {
                    sendError(observer, .CannotSave(name: name, underlying: error as NSError))
                }
            }, ifFailure: {
                sendError(observer, .CannotSave(name: name, underlying: $0))
            })
        }

        return producer |> observeOn(QueueScheduler.mainQueueScheduler)
    }
}
