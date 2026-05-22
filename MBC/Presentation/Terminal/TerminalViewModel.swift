import Foundation

@MainActor
final class TerminalViewModel: ObservableObject {
    @Published private(set) var state: TerminalState = .idle
    @Published var isLocked = false

    private let checkOutUseCase: CheckOutUseCaseProtocol

    init(checkOutUseCase: CheckOutUseCaseProtocol) {
        self.checkOutUseCase = checkOutUseCase
    }

    func performCheckOut() {
        state = .scanning
        Task {
            do {
                let (card, tariff) = try await checkOutUseCase.execute()
                state = .success(card, tariff)
            } catch let error as MBCError {
                state = .error(error.userMessage)
            } catch {
                state = .error("Gagal check-out")
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
