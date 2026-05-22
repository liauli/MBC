@testable import MBC
import XCTest

@MainActor
final class GateViewModelTests: XCTestCase {
    private var sut: GateViewModel!
    private var mockCheckIn: MockCheckInUseCase!

    override func setUp() {
        super.setUp()
        mockCheckIn = MockCheckInUseCase()
        sut = GateViewModel(checkInUseCase: mockCheckIn)
    }

    func test_performCheckIn_success() async throws {
        // Given
        let card = makeTestCard()
        mockCheckIn.result = .success(card)

        // When
        sut.performCheckIn()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.state, .success(card))
    }

    func test_performCheckIn_failure() async throws {
        // Given
        mockCheckIn.result = .failure(.alreadyCheckedIn)

        // When
        sut.performCheckIn()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        if case .error = sut.state {} else { XCTFail("Expected error state") }
    }

    func test_lock_unlock() {
        // When
        sut.lock()
        XCTAssertTrue(sut.isLocked)

        sut.unlock()
        XCTAssertFalse(sut.isLocked)
    }

    func test_reset() async throws {
        // Given
        mockCheckIn.result = .success(makeTestCard())
        sut.performCheckIn()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        sut.reset()

        // Then
        XCTAssertEqual(sut.state, .idle)
    }

    private func makeTestCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(memberID: "MBC-0001", name: "Ahmad", registeredDate: Date()),
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .checkedIn(time: Date(), isSimulated: false),
            transactions: [],
            writeCounter: 1
        )
    }
}
