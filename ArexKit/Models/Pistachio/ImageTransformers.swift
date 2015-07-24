import Pistachio
import UIKit
import ValueTransformer

struct ImageTransformers {
    static func JPEGData(quality: CGFloat = 0.7) -> ReversibleValueTransformer<UIImage, NSData, String> {
        return ReversibleValueTransformer(transformClosure: { value in
            if let data = UIImageJPEGRepresentation(value, quality) {
                return .Success(data)
            } else {
                return .Failure("Could not create JPEG data (q=\(quality)) from data")
            }
        }, reverseTransformClosure: { value in
            if let image = UIImage(data: value) {
                return .Success(image)
            } else {
                return .Failure("Could not create UIImage from data")
            }
        })
    }

    static let PNGData = ReversibleValueTransformer<UIImage, NSData, String>(transformClosure: { value in
        if let data = UIImagePNGRepresentation(value) {
            return .Success(data)
        } else {
            return .Failure("Could not create PNG data from data")
        }
    }, reverseTransformClosure: { value in
        if let image = UIImage(data: value) {
            return .Success(image)
        } else {
            return .Failure("Could not create UIImage from data")
        }
    })
}
