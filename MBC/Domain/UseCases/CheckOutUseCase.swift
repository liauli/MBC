import Foundation

final class CheckOutUseCase: CheckOutUseCaseProtocol {
    private let cardRepository: CardRepositoryProtocol

    init(cardRepository: CardRepositoryProtocol) {
        self.cardRepository = cardRepository
    }

    func execute(completion: @escaping (Result<(MemberCard, TariffResult), MBCError>) -> Void) {
        var tariffResult: TariffResult?

        cardRepository.readAndUpdateCard { card in
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
        } completion: { result in
            switch result {
            case let .success(card):
                guard let tariff = tariffResult else {
                    completion(.failure(.notCheckedIn))
                    return
                }
                completion(.success((card, tariff)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
