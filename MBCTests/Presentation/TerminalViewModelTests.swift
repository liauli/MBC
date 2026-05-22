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

    // MARK: - performCheckOut

    func test_performCheckOut_success_setsSuccess() {
        // Given
        let card = makeTestCard()
        let tariff = TariffResult(duration: 3600, hours: 1, amount: 5000)
        mockCheckOut.result = .success((card, tariff))

        // When
        sut.performCheckOut()

        // Then
        XCTAssertEqual(sut.state, .success(card, tariff))
    }

    func test_performCheckOut_failure_setsError() {
        // Given
        mockCheckOut.result = .failure(.notCheckedIn)

        // When
        sut.performCheckOut()

        // Then
        XCTAssertEqual(sut.state, .error(MBCError.notCheckedIn.localizedDescription))
    }

    // MARK: - Lock

    func test_performCheckOut_whenLocked_doesNothing() {
        // Given
        sut.isLocked = true
        let card = makeTestCard()
        let tariff = TariffResult(duration: 3600, hours: 1, amount: 5000)
        mockCheckOut.result = .success((card, tariff))

        // When
        sut.performCheckOut()

        // Then
        XCTAssertEqual(sut.state, .idle)
        XCTAssertFalse(mockCheckOut.executeCalled)
    }

    func test_performCheckOut_whenUnlocked_proceeds() {
        // Given
        sut.isLocked = false
        let card = makeTestCard()
        let tariff = TariffResult(duration: 3600, hours: 1, amount: 5000)
        mockCheckOut.result = .success((card, tariff))

        // When
        sut.performCheckOut()

        // Then
        XCTAssertTrue(mockCheckOut.executeCalled)
    }

    // MARK: - reset

    func test_reset_setsIdle() {
        // Given
        let card = makeTestCard()
        let tariff = TariffResult(duration: 3600, hours: 1, amount: 5000)
        mockCheckOut.result = .success((card, tariff))
        sut.performCheckOut()

        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.state, .idle)
    }

    // MARK: - Helpers

    private func makeTestCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(
                memberID: "abc12345",
                name: "Ahmad",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: 45000, lastTopUpAmount: 50000),
            visitState: .idle,
            transactions: [],
            writeCounter: 3
        )
    }
}

// MARK: - Mock

private final class MockCheckOutUseCase: CheckOutUseCaseProtocol {
    var result: Result<(MemberCard, TariffResult), MBCError> = .failure(.notCheckedIn)
    var executeCalled = false

    func execute(completion: @escaping (Result<(MemberCard, TariffResult), MBCError>) -> Void) {
        executeCalled = true
        completion(result)
    }
}
