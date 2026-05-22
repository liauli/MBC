import Foundation

enum PINState: Equatable {
    case idle
    case needsSetup
    case authenticated
    case wrongPIN(remaining: Int)
    case locked
    case pinChanged
    case error(String)
}
