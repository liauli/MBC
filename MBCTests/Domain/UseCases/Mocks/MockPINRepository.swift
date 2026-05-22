import Foundation
@testable import MBC

final class MockPINRepository: PINRepositoryProtocol {
    var storedPin: String?
    var setPinCalled = false
    var setPinResult = true

    func setPin(_ pin: String) -> Bool {
        setPinCalled = true
        guard setPinResult else { return false }
        storedPin = pin
        return true
    }

    func verifyPin(_ pin: String) -> Bool {
        storedPin == pin
    }

    func isPinSet() -> Bool {
        storedPin != nil
    }
}
