import Foundation

@MainActor
final class ScoutViewModel: ObservableObject {
    @Published private(set) var state: ScoutState = .idle

    private let readCardUseCase: ReadCardUseCaseProtocol

    init(readCardUseCase: ReadCardUseCaseProtocol) {
        self.readCardUseCase = readCardUseCase
    }

    func scan() {
        state = .scanning
        Task {
            do {
                let card = try await readCardUseCase.execute()
                state = .success(card)
            } catch let error as MBCError {
                state = .error(error.userMessage)
            } catch {
                state = .error("Gagal membaca kartu")
            }
        }
    }

    func reset() {
        state = .idle
    }
}
