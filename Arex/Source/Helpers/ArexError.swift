import Foundation

enum ArexError: Int, ErrorRepresentable {
    static let domain = "ArexError"

    case Unknown

    var code: Int {
        return rawValue
    }

    var description: String {
        switch self {
        case .Unknown:
            return NSLocalizedString("An unknown error occurred.", comment: "")
        }
    }

    var failureReason: String? {
        switch self {
        case .Unknown:
            return nil
        }
    }
}
