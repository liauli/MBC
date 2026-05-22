import Foundation

final class ChangePinUseCase: ChangePinUseCaseProtocol {
    private let repository: PINRepositoryProtocol

    init(repository: PINRepositoryProtocol) {
        self.repository = repository
    }

    func execute(currentPin: String?, newPin: String) async throws {
        if let currentPin {
            guard repository.verifyPin(currentPin) else {
                throw MBCError.wrongPin
            }
        }
        guard isValidPin(newPin) else {
            throw MBCError.invalidPin
        }
        let success = repository.setPin(newPin)
        guard success else { throw MBCError.encryptionFailed }
    }

    private func isValidPin(_ pin: String) -> Bool {
        pin.count == 4 && pin.allSatisfy(\.isNumber)
    }
}
