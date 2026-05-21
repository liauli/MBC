@testable import MBC
import XCTest

final class TopUpUseCaseTests: XCTestCase {
    private var sut: TopUpUseCase!
    private var mockRepository: MockCardRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardRepository()
        sut = TopUpUseCase(repository: mockRepository)
    }

    func test_execute_validAmount_updatesBalance() {
        // Given
        mockRepository.readAndUpdateResult = .success(makeTestCard(balance: 10000))

        // When
        var result: Result<MemberCard, MBCError>?
        sut.execute(amount: 50000) { result = $0 }

        // Then
        if case let .success(card) = result {
            XCTAssertEqual(card.wallet.balance, 60000)
            XCTAssertEqual(card.wallet.lastTopUpAmount, 50000)
            XCTAssertEqual(card.transactions.last?.type, .topUp)
            XCTAssertEqual(card.transactions.last?.amount, 50000)
        } else {
            XCTFail("Expected success")
        }
    }

    func test_execute_zeroAmount_fails() {
        // When
        var error: MBCError?
        sut.execute(amount: 0) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidAmount)
    }

    func test_execute_negativeAmount_fails() {
        // When
        var error: MBCError?
        sut.execute(amount: -1000) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidAmount)
    }

    func test_execute_exceedsMaxTopUp_fails() {
        // When
        var error: MBCError?
        sut.execute(amount: 1_000_001) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidAmount)
    }

    func test_execute_exceedsMaxBalance_fails() {
        // Given
        mockRepository.readAndUpdateResult = .success(makeTestCard(balance: 4_900_000))

        // When
        var error: MBCError?
        sut.execute(amount: 200_000) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidAmount)
    }

    func test_execute_nfcFails_returnsError() {
        // Given
        mockRepository.readAndUpdateResult = .failure(.nfcReadFailed)

        // When
        var error: MBCError?
        sut.execute(amount: 10000) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .nfcReadFailed)
    }

    func test_execute_transactionsFIFO_keepsMax5() {
        // Given
        let existingTransactions = (0 ..< 5).map { i in
            Transaction(
                type: .topUp,
                amount: 1000 * (i + 1),
                timestamp: Date(timeIntervalSince1970: Double(1_690_000_000 + i))
            )
        }
        mockRepository.readAndUpdateResult = .success(makeTestCard(balance: 10000, transactions: existingTransactions))

        // When
        var result: Result<MemberCard, MBCError>?
        sut.execute(amount: 5000) { result = $0 }

        // Then
        if case let .success(card) = result {
            XCTAssertEqual(card.transactions.count, 5)
            XCTAssertEqual(card.transactions.last?.amount, 5000)
        } else {
            XCTFail("Expected success")
        }
    }

    private func makeTestCard(balance: Int = 50000, transactions: [Transaction] = []) -> MemberCard {
        MemberCard(
            identity: MemberIdentity(
                memberID: "abc12345",
                name: "Ahmad",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: balance, lastTopUpAmount: 0),
            visitState: .idle,
            transactions: transactions,
            writeCounter: 1
        )
    }
}
