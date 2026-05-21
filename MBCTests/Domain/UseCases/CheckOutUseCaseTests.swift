@testable import MBC
import XCTest

final class CheckOutUseCaseTests: XCTestCase {
    private var sut: CheckOutUseCase!
    private var mockRepository: MockCardRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardRepository()
        sut = CheckOutUseCase(cardRepository: mockRepository)
    }

    func test_execute_checkedInWithSufficientBalance_succeeds() {
        // Given
        let checkInTime = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 7200)
        let card = makeCheckedInCard(checkInTime: checkInTime, balance: 50000)
        mockRepository.readResult = .success(card)
        var result: Result<(MemberCard, TariffResult), MBCError>?

        // When
        sut.execute { result = $0 }

        // Then
        guard case let .success((updatedCard, tariff)) = result else {
            XCTFail("Expected success")
            return
        }
        XCTAssertEqual(updatedCard.visitState, .idle)
        XCTAssertEqual(tariff.hours, 2)
        XCTAssertEqual(tariff.amount, 4000)
        XCTAssertEqual(updatedCard.wallet.balance, 46000)
        XCTAssertEqual(updatedCard.transactions.last?.type, .checkOut)
    }

    func test_execute_notCheckedIn_fails() {
        // Given
        let card = makeIdleCard()
        mockRepository.readResult = .success(card)
        var result: Result<(MemberCard, TariffResult), MBCError>?

        // When
        sut.execute { result = $0 }

        // Then
        guard case let .failure(error) = result else {
            XCTFail("Expected failure")
            return
        }
        XCTAssertEqual(error, .notCheckedIn)
    }

    func test_execute_insufficientBalance_fails() {
        // Given
        let checkInTime = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 7200)
        let card = makeCheckedInCard(checkInTime: checkInTime, balance: 1000)
        mockRepository.readResult = .success(card)
        var result: Result<(MemberCard, TariffResult), MBCError>?

        // When
        sut.execute { result = $0 }

        // Then
        guard case let .failure(error) = result else {
            XCTFail("Expected failure")
            return
        }
        XCTAssertEqual(error, .insufficientBalance(required: 4000, available: 1000))
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

    private func makeCheckedInCard(checkInTime: Date, balance: Int) -> MemberCard {
        MemberCard(
            identity: MemberIdentity(memberID: "MBC-0001", name: "Ahmad", registeredDate: Date()),
            wallet: Wallet(balance: balance, lastTopUpAmount: 50000),
            visitState: .checkedIn(time: checkInTime, isSimulated: false),
            transactions: [],
            writeCounter: 1
        )
    }
}
