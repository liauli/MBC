import Foundation

final class VerifyPinUseCase: VerifyPinUseCaseProtocol {
    private let repository: PINRepositoryProtocol

    init(repository: PINRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pin: String) -> Bool {
        repository.verifyPin(pin)
    }
}
