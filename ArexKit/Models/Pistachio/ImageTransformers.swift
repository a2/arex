import Pistachio
import UIKit
import ValueTransformer

struct ImageTransformers {
    static func JPEGData(quality: CGFloat = 0.7) -> ReversibleValueTransformer<UIImage, NSData, String> {
        return ReversibleValueTransformer(transformClosure: { value in
            if let data = UIImageJPEGRepresentation(value, quality) {
                return .success(data)
            } else {
                return .failure("Could not create JPEG data (q=\(quality)) from data")
            }
        }, reverseTransformClosure: { value in
            if let image = UIImage(data: value) {
                return .success(image)
            } else {
                return .failure("Could not create UIImage from data")
            }
        })
    }

    static let PNGData = ReversibleValueTransformer<UIImage, NSData, String>(transformClosure: { value in
        if let data = UIImagePNGRepresentation(value) {
            return .success(data)
        } else {
            return .failure("Could not create PNG data from data")
        }
    }, reverseTransformClosure: { value in
        if let image = UIImage(data: value) {
            return .success(image)
        } else {
            return .failure("Could not create UIImage from data")
        }
    })
}
