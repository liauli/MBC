@testable import MBC
import XCTest

final class CheckInUseCaseTests: XCTestCase {
    private var sut: CheckInUseCase!
    private var mockRepository: MockCardRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardRepository()
        sut = CheckInUseCase(cardRepository: mockRepository)
    }

    func test_execute_idleCard_checksIn() async throws {
        // Given
        mockRepository.readResult = .success(makeIdleCard())
        let simulatedTime = Date(timeIntervalSince1970: 1_700_000_000)

        // When
        let result = try await sut.execute(simulatedTime: simulatedTime)

        // Then
        XCTAssertEqual(result.visitState, .checkedIn(time: simulatedTime, isSimulated: true))
        XCTAssertEqual(result.transactions.last?.type, .checkIn)
        XCTAssertEqual(result.writeCounter, 1)
    }

    func test_execute_alreadyCheckedIn_throws() async {
        // Given
        mockRepository.readResult = .success(makeCheckedInCard())

        // When / Then
        do {
            _ = try await sut.execute(simulatedTime: nil)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .alreadyCheckedIn)
        }
    }

    func test_execute_noSimulatedTime_usesRealTime() async throws {
        // Given
        mockRepository.readResult = .success(makeIdleCard())

        // When
        let result = try await sut.execute(simulatedTime: nil)

        // Then
        if case let .checkedIn(_, isSimulated) = result.visitState {
            XCTAssertFalse(isSimulated)
        } else {
            XCTFail("Expected checkedIn state")
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

    private func makeCheckedInCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(memberID: "MBC-0001", name: "Ahmad", registeredDate: Date()),
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .checkedIn(time: Date(), isSimulated: false),
            transactions: [],
            writeCounter: 1
        )
    }
}
