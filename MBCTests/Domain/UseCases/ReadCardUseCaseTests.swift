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

    func test_execute_success_returnsCard() {
        // Given
        let expectedCard = makeTestCard()
        mockRepository.readCardResult = .success(expectedCard)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.execute { result = $0 }

        // Then
        XCTAssertEqual(result, .success(expectedCard))
    }

    func test_execute_failure_returnsError() {
        // Given
        mockRepository.readCardResult = .failure(.nfcReadFailed)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.execute { result = $0 }

        // Then
        XCTAssertEqual(result, .failure(.nfcReadFailed))
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
