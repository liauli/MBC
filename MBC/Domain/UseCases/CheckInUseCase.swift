import Foundation

final class CheckInUseCase: CheckInUseCaseProtocol {
    private let cardRepository: CardRepositoryProtocol

    init(cardRepository: CardRepositoryProtocol) {
        self.cardRepository = cardRepository
    }

    func execute(
        simulatedTime: Date?,
        completion: @escaping (Result<MemberCard, MBCError>) -> Void
    ) {
        let checkInTime = simulatedTime ?? Date()
        let isSimulated = simulatedTime != nil

        cardRepository.readAndUpdateCard({ card in
            guard case .idle = card.visitState else {
                throw MBCError.alreadyCheckedIn
            }
            var updatedCard = card
            updatedCard.visitState = .checkedIn(time: checkInTime, isSimulated: isSimulated)
            updatedCard.transactions.append(
                Transaction(type: .checkIn, amount: 0, timestamp: checkInTime)
            )
            updatedCard.writeCounter += 1
            return updatedCard
        }, completion: completion)
    }
}
