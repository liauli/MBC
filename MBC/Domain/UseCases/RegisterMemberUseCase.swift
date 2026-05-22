import Foundation

final class RegisterMemberUseCase: RegisterMemberUseCaseProtocol {
    private let repository: CardRepositoryProtocol

    init(repository: CardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String) async throws -> MemberCard {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 32 else {
            throw MBCError.invalidName
        }
        let card = MemberCard(
            identity: MemberIdentity(memberID: generateID(), name: trimmed, registeredDate: Date()),
            wallet: Wallet(balance: 0, lastTopUpAmount: 0),
            visitState: .idle,
            transactions: [],
            writeCounter: 0
        )
        try await repository.writeCard(card)
        return card
    }

    private func generateID() -> String {
        String(UUID().uuidString.prefix(8).lowercased())
    }
}
