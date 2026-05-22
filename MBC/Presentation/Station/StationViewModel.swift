import Foundation

// MARK: - State

enum StationState: Equatable {
    case idle
    case loading
    case cardBlank
    case cardExists(MemberCard)
    case registerSuccess(MemberCard)
    case topUpReady(MemberCard)
    case topUpSuccess(MemberCard)
    case error(String)
}

// MARK: - ViewModel

@MainActor
final class StationViewModel: ObservableObject {
    @Published private(set) var state: StationState = .idle

    private let readCardUseCase: ReadCardUseCaseProtocol
    private let registerMemberUseCase: RegisterMemberUseCaseProtocol
    private let topUpUseCase: TopUpUseCaseProtocol

    init(
        readCardUseCase: ReadCardUseCaseProtocol,
        registerMemberUseCase: RegisterMemberUseCaseProtocol,
        topUpUseCase: TopUpUseCaseProtocol
    ) {
        self.readCardUseCase = readCardUseCase
        self.registerMemberUseCase = registerMemberUseCase
        self.topUpUseCase = topUpUseCase
    }

    func scanForRegister() {
        state = .loading
        readCardUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .success(card):
                    self.state = .cardExists(card)
                case .failure(.cardNotRegistered):
                    self.state = .cardBlank
                case let .failure(error):
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    func register(name: String) {
        state = .loading
        registerMemberUseCase.execute(name: name) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .success(card):
                    self.state = .registerSuccess(card)
                case let .failure(error):
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    func readForTopUp() {
        state = .loading
        readCardUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .success(card):
                    self.state = .topUpReady(card)
                case let .failure(error):
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    func confirmTopUp(amount: Int) {
        state = .loading
        topUpUseCase.execute(amount: amount) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .success(card):
                    self.state = .topUpSuccess(card)
                case let .failure(error):
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }

    func reset() {
        state = .idle
    }
}
