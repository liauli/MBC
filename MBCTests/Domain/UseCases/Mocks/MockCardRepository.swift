import Foundation
@testable import MBC

final class MockCardRepository: CardRepositoryProtocol {
    var readResult: Result<MemberCard, MBCError> = .failure(.nfcReadFailed)
    var readCardResult: Result<MemberCard, MBCError> {
        get { readResult }
        set { readResult = newValue }
    }

    var writeResult: Result<Void, MBCError> = .success(())
    var writeCardResult: Result<Void, MBCError> {
        get { writeResult }
        set { writeResult = newValue }
    }

    var readAndUpdateResult: Result<MemberCard, MBCError>?
    var readCalled = false
    var writeCalled = false
    var readAndUpdateCalled = false
    var lastWrittenCard: MemberCard?
    var writtenCard: MemberCard? {
        get { lastWrittenCard }
        set { lastWrittenCard = newValue }
    }

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
        let sourceResult = readAndUpdateResult ?? readResult
        switch sourceResult {
        case let .success(card):
            do {
                let updatedCard = try update(card)
                lastWrittenCard = updatedCard
                completion(.success(updatedCard))
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
