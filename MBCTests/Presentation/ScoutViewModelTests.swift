@testable import MBC
import XCTest

@MainActor
final class ScoutViewModelTests: XCTestCase {
    private var sut: ScoutViewModel!
    private var mockReadCard: MockReadCardUseCase!

    override func setUp() {
        super.setUp()
        mockReadCard = MockReadCardUseCase()
        sut = ScoutViewModel(readCardUseCase: mockReadCard)
    }

    func test_scan_success() async throws {
        // Given
        let card = makeTestCard()
        mockReadCard.result = .success(card)

        // When
        sut.scan()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.state, .success(card))
    }

    func test_scan_failure() async throws {
        // Given
        mockReadCard.result = .failure(.nfcReadFailed)

        // When
        sut.scan()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        if case .error = sut.state {} else { XCTFail("Expected error state") }
    }

    func test_reset() {
        sut.reset()
        XCTAssertEqual(sut.state, .idle)
    }

    private func makeTestCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(memberID: "MBC-0001", name: "Ahmad", registeredDate: Date()),
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .idle,
            transactions: [],
            writeCounter: 1
        )
    }
}
