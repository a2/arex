import Pistachio
import LlamaKit
import UIKit

struct ImageTransformers {
    static func JPEGData(quality: CGFloat = 0.7) -> ValueTransformer<UIImage, NSData, NSError> {
        return ValueTransformer(transformClosure: { value in
            if let data = UIImageJPEGRepresentation(value, quality) {
                return success(data)
            } else {
                return failure("Could not create JPEG data (q=\(quality)) from data")
            }
        }, reverseTransformClosure: { value in
            if let image = UIImage(data: value) {
                return success(image)
            } else {
                return failure("Could not create UIImage from data")
            }
        })
    }

    static let PNGData = ValueTransformer<UIImage, NSData, NSError>(transformClosure: { value in
        if let data = UIImagePNGRepresentation(value) {
            return success(data)
        } else {
            return failure("Could not create PNG data from data")
        }
    }, reverseTransformClosure: { value in
        if let image = UIImage(data: value) {
            return success(image)
        } else {
            return failure("Could not create UIImage from data")
        }
    })
}
