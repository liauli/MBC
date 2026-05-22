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

    func readCard() async throws -> MemberCard {
        readCalled = true
        switch readResult {
        case let .success(card): return card
        case let .failure(error): throw error
        }
    }

    func writeCard(_ card: MemberCard) async throws {
        writeCalled = true
        lastWrittenCard = card
        switch writeResult {
        case .success: return
        case let .failure(error): throw error
        }
    }

    func readAndUpdateCard(_ update: (MemberCard) throws -> MemberCard) async throws -> MemberCard {
        readAndUpdateCalled = true
        let sourceResult = readAndUpdateResult ?? readResult
        switch sourceResult {
        case let .success(card):
            let updatedCard = try update(card)
            lastWrittenCard = updatedCard
            return updatedCard
        case let .failure(error):
            throw error
        }
    }
}
