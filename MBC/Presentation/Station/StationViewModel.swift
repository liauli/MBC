import Foundation

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
        Task {
            do {
                let card = try await readCardUseCase.execute()
                state = .cardExists(card)
            } catch MBCError.cardNotRegistered {
                state = .cardBlank
            } catch {
                state = .cardBlank
            }
        }
    }

    func register(name: String) {
        state = .loading
        Task {
            do {
                let card = try await registerMemberUseCase.execute(name: name)
                state = .registerSuccess(card)
            } catch let error as MBCError {
                state = .error(error.localizedDescription)
            } catch {
                state = .error("Gagal mendaftarkan anggota")
            }
        }
    }

    func readForTopUp() {
        state = .loading
        Task {
            do {
                let card = try await readCardUseCase.execute()
                state = .topUpReady(card)
            } catch let error as MBCError {
                state = .error(error.localizedDescription)
            } catch {
                state = .error("Gagal membaca kartu")
            }
        }
    }

    func confirmTopUp(amount: Int) {
        state = .loading
        Task {
            do {
                let card = try await topUpUseCase.execute(amount: amount)
                state = .topUpSuccess(card)
            } catch let error as MBCError {
                state = .error(error.localizedDescription)
            } catch {
                state = .error("Gagal top-up")
            }
        }
    }

    func reset() {
        state = .idle
    }
}
