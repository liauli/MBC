import Foundation

final class CheckOutUseCase: CheckOutUseCaseProtocol {
    private let cardRepository: CardRepositoryProtocol

    init(cardRepository: CardRepositoryProtocol) {
        self.cardRepository = cardRepository
    }

    func execute() async throws -> (MemberCard, TariffResult) {
        var tariffResult: TariffResult?
        let updatedCard = try await cardRepository.readAndUpdateCard { card in
            guard case let .checkedIn(checkInTime, _) = card.visitState else {
                throw MBCError.notCheckedIn
            }
            let tariff = TariffCalculator.calculate(checkIn: checkInTime, checkOut: Date())
            guard card.wallet.balance >= tariff.amount else {
                throw MBCError.insufficientBalance(required: tariff.amount, available: card.wallet.balance)
            }
            tariffResult = tariff
            var updatedCard = card
            updatedCard.wallet.balance -= tariff.amount
            updatedCard.visitState = .idle
            updatedCard.transactions.append(
                Transaction(type: .checkOut, amount: tariff.amount, timestamp: Date())
            )
            updatedCard.writeCounter += 1
            return updatedCard
        }
        guard let tariff = tariffResult else { throw MBCError.notCheckedIn }
        return (updatedCard, tariff)
    }
}
