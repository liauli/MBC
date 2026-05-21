import Foundation

final class TopUpUseCase: TopUpUseCaseProtocol {
    private let repository: CardRepositoryProtocol
    private static let maxBalance = 5_000_000
    private static let maxTopUp = 1_000_000

    init(repository: CardRepositoryProtocol) {
        self.repository = repository
    }

    func execute(amount: Int, completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        guard amount > 0, amount <= Self.maxTopUp else {
            completion(.failure(.invalidAmount))
            return
        }
        repository.readAndUpdateCard({ card in
            let newBalance = card.wallet.balance + amount
            guard newBalance <= Self.maxBalance else {
                throw MBCError.invalidAmount
            }
            var updated = card
            updated.wallet.balance = newBalance
            updated.wallet.lastTopUpAmount = amount
            updated.transactions = Self.appendTransaction(
                Transaction(type: .topUp, amount: amount, timestamp: Date()),
                to: card.transactions
            )
            updated.writeCounter += 1
            return updated
        }, completion: { result in
            completion(result)
        })
    }

    private static func appendTransaction(_ transaction: Transaction, to existing: [Transaction]) -> [Transaction] {
        var list = existing
        list.append(transaction)
        if list.count > 5 { list.removeFirst(list.count - 5) }
        return list
    }
}
