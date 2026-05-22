@testable import MBC
import XCTest

@MainActor
final class TerminalViewModelTests: XCTestCase {
    private var sut: TerminalViewModel!
    private var mockCheckOut: MockCheckOutUseCase!

    override func setUp() {
        super.setUp()
        mockCheckOut = MockCheckOutUseCase()
        sut = TerminalViewModel(checkOutUseCase: mockCheckOut)
    }

    func test_performCheckOut_success() async throws {
        // Given
        let card = makeTestCard()
        let tariff = TariffResult(duration: 7200, hours: 2, amount: 4000)
        mockCheckOut.result = .success((card, tariff))

        // When
        sut.performCheckOut()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.state, .success(card, tariff))
    }

    func test_performCheckOut_failure() async throws {
        // Given
        mockCheckOut.result = .failure(.notCheckedIn)

        // When
        sut.performCheckOut()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        if case .error = sut.state {} else { XCTFail("Expected error state") }
    }

    func test_lock_unlock() {
        sut.lock()
        XCTAssertTrue(sut.isLocked)
        sut.unlock()
        XCTAssertFalse(sut.isLocked)
    }

    private func makeTestCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(memberID: "MBC-0001", name: "Ahmad", registeredDate: Date()),
            wallet: Wallet(balance: 46000, lastTopUpAmount: 50000),
            visitState: .idle,
            transactions: [],
            writeCounter: 2
        )
    }
}
