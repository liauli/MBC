import Foundation

final class ReadCardUseCase: ReadCardUseCaseProtocol {
    private let repository: CardRepositoryProtocol

    init(repository: CardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        repository.readCard(completion: completion)
    }
}
