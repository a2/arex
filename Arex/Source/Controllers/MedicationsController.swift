import LlamaKit
import MessagePack
import ReactiveCocoa

/// The file extension to use when saving `Medication` instances.
private let MedicationFileExtension: String = "rx"

class MedicationsController {
    let directoryURL: NSURL
    let fileManager = NSFileManager()

    init(directoryURL: NSURL) {
        self.directoryURL = directoryURL
    }

    private func loadMedications() -> (medications: [Medication]?, error: NSError?) {
        var error: NSError?
        if let directoryContents = fileManager.contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: [], options: .SkipsHiddenFiles, error: nil) as? [NSURL] {
            let medications = lazy(directoryContents)
                .filter({ (url: NSURL) in
                    return url.pathExtension == MedicationFileExtension
                })
                .map({ (url: NSURL) -> Medication? in
                    if let data = NSData(contentsOfURL: url), messagePackValue = unpack(data) {
                        return Adapters.medication.decode(Medication(), from: messagePackValue).value
                    } else {
                        return nil
                    }
                })
                /*.flatMap({ (medication: Medication?) -> [Medication] in
                    if let medication = medication {
                        return [medication]
                    } else {
                        return []
                    }
                })*/
                .filter({ $0 != nil })
                .map({ $0! }).array
            return (medications, nil)
        } else {
            return (nil, error)
        }
    }

    func medications() -> SignalProducer<[Medication], NSError> {
        return monitorDirectory(directoryURL).lift(tryMap({ _ in
            let (medications, error) = self.loadMedications()
            if let medications = medications {
                return success(medications)
            } else {
                return failure(error!)
            }
        }))
    }
}
