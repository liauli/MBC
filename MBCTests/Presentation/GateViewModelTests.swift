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

    // MARK: - performCheckIn

    func test_performCheckIn_success_setsSuccess() {
        // Given
        let card = makeTestCard()
        mockCheckIn.result = .success(card)

        // When
        sut.performCheckIn()

        // Then
        XCTAssertEqual(sut.state, .success(card))
    }

    func test_performCheckIn_failure_setsError() {
        // Given
        mockCheckIn.result = .failure(.alreadyCheckedIn)

        // When
        sut.performCheckIn()

        // Then
        XCTAssertEqual(sut.state, .error(MBCError.alreadyCheckedIn.localizedDescription))
    }

    func test_performCheckIn_simulationMode_passesSimulatedTime() {
        // Given
        let card = makeTestCard()
        mockCheckIn.result = .success(card)
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        sut.isSimulationMode = true
        sut.simulatedTime = fixedDate

        // When
        sut.performCheckIn()

        // Then
        XCTAssertEqual(mockCheckIn.lastSimulatedTime, fixedDate)
    }

    func test_performCheckIn_notSimulationMode_passesNil() {
        // Given
        let card = makeTestCard()
        mockCheckIn.result = .success(card)
        sut.isSimulationMode = false

        // When
        sut.performCheckIn()

        // Then
        XCTAssertNil(mockCheckIn.lastSimulatedTime)
    }

    // MARK: - Lock

    func test_performCheckIn_whenLocked_doesNothing() {
        // Given
        sut.isLocked = true
        mockCheckIn.result = .success(makeTestCard())

        // When
        sut.performCheckIn()

        // Then
        XCTAssertEqual(sut.state, .idle)
        XCTAssertFalse(mockCheckIn.executeCalled)
    }

    func test_performCheckIn_whenUnlocked_proceeds() {
        // Given
        sut.isLocked = false
        mockCheckIn.result = .success(makeTestCard())

        // When
        sut.performCheckIn()

        // Then
        XCTAssertTrue(mockCheckIn.executeCalled)
    }

    // MARK: - reset

    func test_reset_setsIdle() {
        // Given
        mockCheckIn.result = .success(makeTestCard())
        sut.performCheckIn()

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
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .checkedIn(time: Date(), isSimulated: false),
            transactions: [],
            writeCounter: 2
        )
    }
}

// MARK: - Mock

private final class MockCheckInUseCase: CheckInUseCaseProtocol {
    var result: Result<MemberCard, MBCError> = .failure(.nfcReadFailed)
    var executeCalled = false
    var lastSimulatedTime: Date?

    func execute(simulatedTime: Date?, completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        executeCalled = true
        lastSimulatedTime = simulatedTime
        completion(result)
    }
}
