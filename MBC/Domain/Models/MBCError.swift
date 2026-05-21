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
    case serializationFailed
    case deserializationFailed
    case encryptionFailed
    case decryptionFailed
}
