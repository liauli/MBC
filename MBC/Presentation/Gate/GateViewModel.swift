import Foundation

// MARK: - State

enum GateState: Equatable {
    case idle
    case scanning
    case success(MemberCard)
    case error(String)
}

// MARK: - ViewModel

@MainActor
final class GateViewModel: ObservableObject {
    @Published private(set) var state: GateState = .idle
    @Published var isSimulationMode = false
    @Published var simulatedTime = Date()
    @Published var isLocked = false

    private let checkInUseCase: CheckInUseCaseProtocol

    init(checkInUseCase: CheckInUseCaseProtocol) {
        self.checkInUseCase = checkInUseCase
    }

    func performCheckIn() {
        guard !isLocked else { return }
        state = .scanning
        let time: Date? = isSimulationMode ? simulatedTime : nil
        checkInUseCase.execute(simulatedTime: time) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case let .success(card):
                    self.state = .success(card)
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
