import Foundation

// MARK: - State

enum TerminalState: Equatable {
    case idle
    case scanning
    case success(MemberCard, TariffResult)
    case error(String)
}

// MARK: - ViewModel

@MainActor
final class TerminalViewModel: ObservableObject {
    @Published private(set) var state: TerminalState = .idle
    @Published var isLocked = false

    private let checkOutUseCase: CheckOutUseCaseProtocol

    init(checkOutUseCase: CheckOutUseCaseProtocol) {
        self.checkOutUseCase = checkOutUseCase
    }

    func performCheckOut() {
        guard !isLocked else { return }
        state = .scanning
        checkOutUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .success((card, tariff)):
                    self.state = .success(card, tariff)
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
