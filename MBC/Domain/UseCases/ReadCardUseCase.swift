import Foundation

final class ReadCardUseCase: ReadCardUseCaseProtocol {
    private let repository: CardRepositoryProtocol

    init(repository: CardRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> MemberCard {
        try await repository.readCard()
    }
}
