import LlamaKit
import MessagePack_swift
import ReactiveCocoa

class MedicationsController {
    /// The file extension to use when saving `Medication` values.
    static let fileExtension = "rx"

    static let defaultDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
    
    /// The directory in which to save `Medication` values.
    let directoryURL: NSURL

    /// The file manager used to load the contents of `directoryURL`.
    private let fileManager = NSFileManager()

    /// The queue on which `directoryURL` is loaded and its `Medication` contents are unpacked.
    private let queue: dispatch_queue_t = {
        let attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0)
        return dispatch_queue_create("us.pandamonia.Arex.MedicationsController", attr)
    }()

    convenience init() {
        self.init(directoryURL: MedicationsController.defaultDirectoryURL)
    }
    
    /**
        :param: directoryURL The URL of the directory in which to load `Medication` values.
    */
    init(directoryURL: NSURL) {
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
                    let data = NSData(contentsOfURL: fileURL), messagePackValue = unpack(data) {

                    switch Adapters.medication.decode(Medication(), from: messagePackValue) {
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
    /// and sends an `Array` of `Medication` values when the directory's
    /// contents change.
    func medications() -> SignalProducer<[Medication], NSError> {
        return monitorDirectory(directoryURL)
            |> observeOn(QueueScheduler(queue))
            |> tryMap { [unowned self] _ in self.loadMedications() }
            |> observeOn(QueueScheduler.mainQueueScheduler)
    }
}
