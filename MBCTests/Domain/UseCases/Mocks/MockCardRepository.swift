import Foundation
@testable import MBC

final class MockCardRepository: CardRepositoryProtocol {
    var readResult: Result<MemberCard, MBCError> = .failure(.nfcReadFailed)
    var writeResult: Result<Void, MBCError> = .success(())
    var readAndUpdateResult: Result<MemberCard, MBCError>?
    var readCalled = false
    var writeCalled = false
    var readAndUpdateCalled = false
    var lastWrittenCard: MemberCard?

    func readCard(completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        readCalled = true
        completion(readResult)
    }

    func writeCard(_ card: MemberCard, completion: @escaping (Result<Void, MBCError>) -> Void) {
        writeCalled = true
        lastWrittenCard = card
        completion(writeResult)
    }

    func readAndUpdateCard(
        _ update: @escaping (MemberCard) throws -> MemberCard,
        completion: @escaping (Result<MemberCard, MBCError>) -> Void
    ) {
        readAndUpdateCalled = true
        switch readResult {
        case let .success(card):
            do {
                let updatedCard = try update(card)
                lastWrittenCard = updatedCard
                if let overrideResult = readAndUpdateResult {
                    completion(overrideResult)
                } else {
                    completion(.success(updatedCard))
                }
            } catch let error as MBCError {
                completion(.failure(error))
            } catch {
                completion(.failure(.nfcWriteFailed))
            }
        case let .failure(error):
            completion(.failure(error))
        }
    }
}
