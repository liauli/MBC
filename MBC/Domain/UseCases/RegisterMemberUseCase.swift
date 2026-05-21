import Foundation

final class RegisterMemberUseCase: RegisterMemberUseCaseProtocol {
    private let repository: CardRepositoryProtocol

    init(repository: CardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 32 else {
            completion(.failure(.invalidName))
            return
        }
        let card = MemberCard(
            identity: MemberIdentity(
                memberID: generateID(),
                name: trimmed,
                registeredDate: Date()
            ),
            wallet: Wallet(balance: 0, lastTopUpAmount: 0),
            visitState: .idle,
            transactions: [],
            writeCounter: 0
        )
        repository.writeCard(card) { result in
            switch result {
            case .success:
                completion(.success(card))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func generateID() -> String {
        String(UUID().uuidString.prefix(8).lowercased())
    }
}
