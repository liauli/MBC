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

    // MARK: - Initial State

    func test_initialState_isIdle() {
        XCTAssertEqual(sut.state, .idle)
    }

    // MARK: - scanForRegister

    func test_scanForRegister_cardExists_setsCardExists() async {
        let card = makeCard()
        mockReadCard.result = .success(card)

        sut.scanForRegister()
        await Task.yield()

        XCTAssertEqual(sut.state, .cardExists(card))
    }

    func test_scanForRegister_cardNotRegistered_setsCardBlank() async {
        mockReadCard.result = .failure(.cardNotRegistered)

        sut.scanForRegister()
        await Task.yield()

        XCTAssertEqual(sut.state, .cardBlank)
    }

    func test_scanForRegister_nfcFails_setsCardBlank() async {
        mockReadCard.result = .failure(.nfcReadFailed)

        sut.scanForRegister()
        await Task.yield()

        XCTAssertEqual(sut.state, .cardBlank)
    }

    // MARK: - register

    func test_register_success_setsRegisterSuccess() async {
        let card = makeCard()
        mockRegister.result = .success(card)

        sut.register(name: "Ahmad")
        await Task.yield()

        XCTAssertEqual(sut.state, .registerSuccess(card))
    }

    func test_register_failure_setsError() async {
        mockRegister.result = .failure(.invalidName)

        sut.register(name: "")
        await Task.yield()

        if case .error = sut.state {} else {
            XCTFail("Expected error state")
        }
    }

    // MARK: - readForTopUp

    func test_readForTopUp_success_setsTopUpReady() async {
        let card = makeCard()
        mockReadCard.result = .success(card)

        sut.readForTopUp()
        await Task.yield()

        XCTAssertEqual(sut.state, .topUpReady(card))
    }

    func test_readForTopUp_failure_setsError() async {
        mockReadCard.result = .failure(.nfcReadFailed)

        sut.readForTopUp()
        await Task.yield()

        if case .error = sut.state {} else {
            XCTFail("Expected error state")
        }
    }

    // MARK: - confirmTopUp

    func test_confirmTopUp_success_setsTopUpSuccess() async {
        let card = makeCard(balance: 70000)
        mockTopUp.result = .success(card)

        sut.confirmTopUp(amount: 20000)
        await Task.yield()

        XCTAssertEqual(sut.state, .topUpSuccess(card))
    }

    func test_confirmTopUp_failure_setsError() async {
        mockTopUp.result = .failure(.nfcWriteFailed)

        sut.confirmTopUp(amount: 20000)
        await Task.yield()

        if case .error = sut.state {} else {
            XCTFail("Expected error state")
        }
    }

    // MARK: - reset

    func test_reset_setsIdle() async {
        mockReadCard.result = .failure(.nfcReadFailed)
        sut.readForTopUp()
        await Task.yield()

        sut.reset()

        XCTAssertEqual(sut.state, .idle)
    }

    // MARK: - Helpers

    private func makeCard(balance: Int = 50000) -> MemberCard {
        MemberCard(
            identity: MemberIdentity(
                memberID: "MBC-0001",
                name: "Ahmad",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: balance, lastTopUpAmount: 50000),
            visitState: .idle,
            transactions: [],
            writeCounter: 1
        )
    }
}
