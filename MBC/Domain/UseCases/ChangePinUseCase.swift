import Foundation

final class ChangePinUseCase: ChangePinUseCaseProtocol {
    private let repository: PINRepositoryProtocol

    init(repository: PINRepositoryProtocol) {
        self.repository = repository
    }

    func execute(currentPin: String?, newPin: String, completion: @escaping (Result<Void, MBCError>) -> Void) {
        if let currentPin {
            guard repository.verifyPin(currentPin) else {
                completion(.failure(.invalidName))
                return
            }
        }
        guard isValidPin(newPin) else {
            completion(.failure(.invalidName))
            return
        }
        let success = repository.setPin(newPin)
        completion(success ? .success(()) : .failure(.encryptionFailed))
    }

    private func isValidPin(_ pin: String) -> Bool {
        pin.count == 4 && pin.allSatisfy(\.isNumber)
    }
}
