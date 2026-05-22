@testable import MBC
import XCTest

@MainActor
final class StationViewModelTests: XCTestCase {
    private var sut: StationViewModel!
    private var mockReadCard: MockReadCardUseCase!
    private var mockRegister: MockRegisterMemberUseCase!
    private var mockTopUp: MockTopUpUseCase!

    override func setUp() {
        super.setUp()
        mockReadCard = MockReadCardUseCase()
        mockRegister = MockRegisterMemberUseCase()
        mockTopUp = MockTopUpUseCase()
        sut = StationViewModel(
            readCardUseCase: mockReadCard,
            registerMemberUseCase: mockRegister,
            topUpUseCase: mockTopUp
        )
    }

    // MARK: - scanForRegister

    func test_scanForRegister_success_setsCardExists() {
        // Given
        let card = makeTestCard()
        mockReadCard.result = .success(card)

        // When
        sut.scanForRegister()

        // Then
        XCTAssertEqual(sut.state, .cardExists(card))
    }

    func test_scanForRegister_cardNotRegistered_setsCardBlank() {
        // Given
        mockReadCard.result = .failure(.cardNotRegistered)

        // When
        sut.scanForRegister()

        // Then
        XCTAssertEqual(sut.state, .cardBlank)
    }

    func test_scanForRegister_otherError_setsError() {
        // Given
        mockReadCard.result = .failure(.nfcReadFailed)

        // When
        sut.scanForRegister()

        // Then
        XCTAssertEqual(sut.state, .error(MBCError.nfcReadFailed.localizedDescription))
    }

    // MARK: - register

    func test_register_success_setsRegisterSuccess() {
        // Given
        let card = makeTestCard()
        mockRegister.result = .success(card)

        // When
        sut.register(name: "Ahmad")

        // Then
        XCTAssertEqual(sut.state, .registerSuccess(card))
    }

    func test_register_failure_setsError() {
        // Given
        mockRegister.result = .failure(.invalidName)

        // When
        sut.register(name: "")

        // Then
        XCTAssertEqual(sut.state, .error(MBCError.invalidName.localizedDescription))
    }

    // MARK: - readForTopUp

    func test_readForTopUp_success_setsTopUpReady() {
        // Given
        let card = makeTestCard()
        mockReadCard.result = .success(card)

        // When
        sut.readForTopUp()

        // Then
        XCTAssertEqual(sut.state, .topUpReady(card))
    }

    func test_readForTopUp_failure_setsError() {
        // Given
        mockReadCard.result = .failure(.nfcReadFailed)

        // When
        sut.readForTopUp()

        // Then
        XCTAssertEqual(sut.state, .error(MBCError.nfcReadFailed.localizedDescription))
    }

    // MARK: - confirmTopUp

    func test_confirmTopUp_success_setsTopUpSuccess() {
        // Given
        let card = makeTestCard()
        mockTopUp.result = .success(card)

        // When
        sut.confirmTopUp(amount: 50000)

        // Then
        XCTAssertEqual(sut.state, .topUpSuccess(card))
    }

    func test_confirmTopUp_failure_setsError() {
        // Given
        mockTopUp.result = .failure(.insufficientBalance(required: 100_000, available: 50000))

        // When
        sut.confirmTopUp(amount: 100_000)

        // Then
        XCTAssertEqual(
            sut.state,
            .error(MBCError.insufficientBalance(required: 100_000, available: 50000).localizedDescription)
        )
    }

    // MARK: - reset

    func test_reset_setsIdle() {
        // Given
        mockReadCard.result = .success(makeTestCard())
        sut.scanForRegister()

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
            visitState: .idle,
            transactions: [],
            writeCounter: 1
        )
    }
}

// MARK: - Mocks

private final class MockReadCardUseCase: ReadCardUseCaseProtocol {
    var result: Result<MemberCard, MBCError> = .failure(.nfcReadFailed)

    func execute(completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        completion(result)
    }
}

private final class MockRegisterMemberUseCase: RegisterMemberUseCaseProtocol {
    var result: Result<MemberCard, MBCError> = .failure(.invalidName)

    func execute(name: String, completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        completion(result)
    }
}

private final class MockTopUpUseCase: TopUpUseCaseProtocol {
    var result: Result<MemberCard, MBCError> = .failure(.nfcReadFailed)

    func execute(amount: Int, completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        completion(result)
    }
}
