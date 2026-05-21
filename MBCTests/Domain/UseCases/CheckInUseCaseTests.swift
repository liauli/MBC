@testable import MBC
import XCTest

final class CheckInUseCaseTests: XCTestCase {
    private var sut: CheckInUseCase!
    private var mockRepository: MockCardRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardRepository()
        sut = CheckInUseCase(cardRepository: mockRepository)
    }

    func test_execute_idleCard_checksIn() {
        // Given
        let card = makeIdleCard()
        mockRepository.readResult = .success(card)
        let simulatedTime = Date(timeIntervalSince1970: 1_700_000_000)
        var result: Result<MemberCard, MBCError>?

        // When
        sut.execute(simulatedTime: simulatedTime) { result = $0 }

        // Then
        guard case let .success(updatedCard) = result else {
            XCTFail("Expected success")
            return
        }
        XCTAssertEqual(updatedCard.visitState, .checkedIn(time: simulatedTime, isSimulated: true))
        XCTAssertEqual(updatedCard.transactions.last?.type, .checkIn)
        XCTAssertEqual(updatedCard.writeCounter, 1)
    }

    func test_execute_alreadyCheckedIn_fails() {
        // Given
        let card = makeCheckedInCard()
        mockRepository.readResult = .success(card)
        var result: Result<MemberCard, MBCError>?

        // When
        sut.execute(simulatedTime: nil) { result = $0 }

        // Then
        guard case let .failure(error) = result else {
            XCTFail("Expected failure")
            return
        }
        XCTAssertEqual(error, .alreadyCheckedIn)
    }

    func test_execute_noSimulatedTime_usesRealTime() {
        // Given
        let card = makeIdleCard()
        mockRepository.readResult = .success(card)
        var result: Result<MemberCard, MBCError>?

        // When
        sut.execute(simulatedTime: nil) { result = $0 }

        // Then
        guard case let .success(updatedCard) = result else {
            XCTFail("Expected success")
            return
        }
        if case let .checkedIn(_, isSimulated) = updatedCard.visitState {
            XCTAssertFalse(isSimulated)
        } else {
            XCTFail("Expected checkedIn state")
        }
    }

    // MARK: - Helpers

    private func makeIdleCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(memberID: "MBC-0001", name: "Ahmad", registeredDate: Date()),
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .idle,
            transactions: [],
            writeCounter: 0
        )
    }

    private func makeCheckedInCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(memberID: "MBC-0001", name: "Ahmad", registeredDate: Date()),
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .checkedIn(time: Date(), isSimulated: false),
            transactions: [],
            writeCounter: 1
        )
    }
}
