import Foundation

final class PINRepository: PINRepositoryProtocol {
    private let keychain: KeychainWrapperProtocol
    private let pinKey = "mbc.user.pin"

    init(keychain: KeychainWrapperProtocol) {
        self.keychain = keychain
    }

    func setPin(_ pin: String) -> Bool {
        let data = Data(pin.utf8)
        return keychain.save(data, for: pinKey)
    }

    func verifyPin(_ pin: String) -> Bool {
        guard let stored = keychain.read(for: pinKey) else { return false }
        let storedPin = String(data: stored, encoding: .utf8)
        return storedPin == pin
    }

    func isPinSet() -> Bool {
        keychain.read(for: pinKey) != nil
    }
}
