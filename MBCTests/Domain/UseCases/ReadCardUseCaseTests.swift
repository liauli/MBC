@testable import MBC
import XCTest

final class ReadCardUseCaseTests: XCTestCase {
    private var sut: ReadCardUseCase!
    private var mockRepository: MockCardRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardRepository()
        sut = ReadCardUseCase(repository: mockRepository)
    }

    func test_execute_success_returnsCard() async throws {
        // Given
        let expectedCard = makeTestCard()
        mockRepository.readCardResult = .success(expectedCard)

        // When
        let result = try await sut.execute()

        // Then
        XCTAssertEqual(result, expectedCard)
    }

    func test_execute_failure_throws() async {
        // Given
        mockRepository.readCardResult = .failure(.nfcReadFailed)

        // When / Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .nfcReadFailed)
        }
    }

    private func makeTestCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(
                memberID: "abc12345",
                name: "Ahmad",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .idle,
            transactions: [],
            writeCounter: 1
        )
    }
}
