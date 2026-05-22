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

    func test_execute_validAmount_updatesBalance() async throws {
        // Given
        mockRepository.readAndUpdateResult = .success(makeTestCard(balance: 10000))

        // When
        let card = try await sut.execute(amount: 50000)

        // Then
        XCTAssertEqual(card.wallet.balance, 60000)
        XCTAssertEqual(card.wallet.lastTopUpAmount, 50000)
        XCTAssertEqual(card.transactions.last?.type, .topUp)
    }

    func test_execute_zeroAmount_throws() async {
        do {
            _ = try await sut.execute(amount: 0)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .invalidAmount)
        }
    }

    func test_execute_exceedsMaxBalance_throws() async {
        // Given
        mockRepository.readAndUpdateResult = .success(makeTestCard(balance: 4_900_000))

        // When / Then
        do {
            _ = try await sut.execute(amount: 200_000)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .invalidAmount)
        }
    }

    func test_execute_nfcFails_throws() async {
        // Given
        mockRepository.readAndUpdateResult = .failure(.nfcReadFailed)

        // When / Then
        do {
            _ = try await sut.execute(amount: 10000)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .nfcReadFailed)
        }
    }

    private func makeTestCard(balance: Int = 50000) -> MemberCard {
        MemberCard(
            identity: MemberIdentity(
                memberID: "abc12345",
                name: "Ahmad",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: balance, lastTopUpAmount: 0),
            visitState: .idle,
            transactions: [],
            writeCounter: 1
        )
    }
}
