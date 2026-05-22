import Foundation

final class IsPinSetupUseCase: IsPinSetupUseCaseProtocol {
    private let repository: PINRepositoryProtocol

    init(repository: PINRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> Bool {
        repository.isPinSet()
    }
}
