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

    func test_execute_checkedInWithSufficientBalance_succeeds() async throws {
        // Given
        let checkInTime = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 7200)
        mockRepository.readResult = .success(makeCheckedInCard(checkInTime: checkInTime, balance: 50000))

        // When
        let (updatedCard, tariff) = try await sut.execute()

        // Then
        XCTAssertEqual(updatedCard.visitState, .idle)
        XCTAssertEqual(tariff.hours, 2)
        XCTAssertEqual(tariff.amount, 4000)
        XCTAssertEqual(updatedCard.wallet.balance, 46000)
        XCTAssertEqual(updatedCard.transactions.last?.type, .checkOut)
    }

    func test_execute_notCheckedIn_throws() async {
        // Given
        mockRepository.readResult = .success(makeIdleCard())

        // When / Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .notCheckedIn)
        }
    }

    func test_execute_insufficientBalance_throws() async {
        // Given
        let checkInTime = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - 7200)
        mockRepository.readResult = .success(makeCheckedInCard(checkInTime: checkInTime, balance: 1000))

        // When / Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .insufficientBalance(required: 4000, available: 1000))
        }
    }

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
