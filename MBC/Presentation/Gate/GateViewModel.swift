import Foundation

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
        state = .scanning
        Task {
            do {
                let time = isSimulationMode ? simulatedTime : nil
                let card = try await checkInUseCase.execute(simulatedTime: time)
                state = .success(card)
            } catch let error as MBCError {
                state = .error(error.userMessage)
            } catch {
                state = .error("Gagal check-in")
            }
        }
    }

    func lock() {
        isLocked = true
    }

    func unlock() {
        isLocked = false
    }

    func reset() {
        state = .idle
    }
}
