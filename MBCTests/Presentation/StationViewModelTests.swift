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
        await fulfillment(of: sut, matching: { $0.state == .cardExists(card) })
    }

    func test_scanForRegister_cardNotRegistered_setsCardBlank() async {
        mockReadCard.result = .failure(.cardNotRegistered)

        sut.scanForRegister()
        await fulfillment(of: sut, matching: { $0.state == .cardBlank })
    }

    func test_scanForRegister_nfcFails_setsCardBlank() async {
        mockReadCard.result = .failure(.nfcReadFailed)

        sut.scanForRegister()
        await fulfillment(of: sut, matching: { $0.state == .cardBlank })
    }

    // MARK: - register

    func test_register_success_setsRegisterSuccess() async {
        let card = makeCard()
        mockRegister.result = .success(card)

        sut.register(name: "Ahmad")
        await fulfillment(of: sut, matching: { $0.state == .registerSuccess(card) })
    }

    func test_register_failure_setsError() async {
        mockRegister.result = .failure(.invalidName)

        sut.register(name: "")
        await fulfillment(of: sut, matching: { if case .error = $0.state { return true }; return false })
    }

    // MARK: - readForTopUp

    func test_readForTopUp_success_setsTopUpReady() async {
        let card = makeCard()
        mockReadCard.result = .success(card)

        sut.readForTopUp()
        await fulfillment(of: sut, matching: { $0.state == .topUpReady(card) })
    }

    func test_readForTopUp_failure_setsError() async {
        mockReadCard.result = .failure(.nfcReadFailed)

        sut.readForTopUp()
        await fulfillment(of: sut, matching: { if case .error = $0.state { return true }; return false })
    }

    // MARK: - confirmTopUp

    func test_confirmTopUp_success_setsTopUpSuccess() async {
        let card = makeCard(balance: 70000)
        mockTopUp.result = .success(card)

        sut.confirmTopUp(amount: 20000)
        await fulfillment(of: sut, matching: { $0.state == .topUpSuccess(card) })
    }

    func test_confirmTopUp_failure_setsError() async {
        mockTopUp.result = .failure(.nfcWriteFailed)

        sut.confirmTopUp(amount: 20000)
        await fulfillment(of: sut, matching: { if case .error = $0.state { return true }; return false })
    }

    // MARK: - reset

    func test_reset_setsIdle() async {
        mockReadCard.result = .failure(.nfcReadFailed)
        sut.readForTopUp()
        await fulfillment(of: sut, matching: { if case .error = $0.state { return true }; return false })

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

    private func fulfillment(
        of viewModel: StationViewModel,
        matching predicate: @escaping (StationViewModel) -> Bool,
        timeout: TimeInterval = 2
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !predicate(viewModel), Date() < deadline {
            await Task.yield()
        }
        XCTAssertTrue(predicate(viewModel), "State did not match within \(timeout)s. Current: \(viewModel.state)")
    }
}
