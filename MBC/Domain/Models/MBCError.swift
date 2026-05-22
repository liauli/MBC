import Foundation

enum MBCError: Error, Equatable {
    case nfcNotAvailable
    case nfcReadFailed
    case nfcWriteFailed
    case cardNotRegistered
    case alreadyCheckedIn
    case notCheckedIn
    case insufficientBalance(required: Int, available: Int)
    case invalidName
    case invalidAmount
    case wrongPin
    case invalidPin
    case serializationFailed
    case deserializationFailed
    case encryptionFailed
    case decryptionFailed

    var userMessage: String {
        switch self {
        case .nfcNotAvailable:
            getString("error.nfc.unavailable")
        case .nfcReadFailed:
            getString("error.nfc.read")
        case .nfcWriteFailed:
            getString("error.nfc.write")
        case .cardNotRegistered:
            getString("error.card.unregistered")
        case .alreadyCheckedIn:
            getString("error.already.checkedin")
        case .notCheckedIn:
            getString("error.not.checkedin")
        case let .insufficientBalance(required, available):
            getString("error.insufficient.balance", required.currencyFormatted, available.currencyFormatted)
        case .invalidName:
            getString("error.invalid.name")
        case .invalidAmount:
            getString("error.invalid.amount")
        case .wrongPin:
            getString("error.wrong.pin")
        case .invalidPin:
            getString("error.invalid.pin")
        case .serializationFailed:
            getString("error.serialization")
        case .deserializationFailed:
            getString("error.deserialization")
        case .encryptionFailed:
            getString("error.encryption")
        case .decryptionFailed:
            getString("error.decryption")
        }
    }
}
