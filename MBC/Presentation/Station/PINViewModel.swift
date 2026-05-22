import Foundation

@MainActor
final class PINViewModel: ObservableObject {
    @Published private(set) var state: PINState = .idle

    private let changePinUseCase: ChangePinUseCaseProtocol
    private let verifyPinUseCase: VerifyPinUseCaseProtocol
    private let isPinSetupUseCase: IsPinSetupUseCaseProtocol
    private var attempts = 0
    private static let maxAttempts = 3
    private static let lockDuration: TimeInterval = 30

    var needsSetup: Bool {
        !isPinSetupUseCase.execute()
    }

    init(
        changePinUseCase: ChangePinUseCaseProtocol,
        verifyPinUseCase: VerifyPinUseCaseProtocol,
        isPinSetupUseCase: IsPinSetupUseCaseProtocol
    ) {
        self.changePinUseCase = changePinUseCase
        self.verifyPinUseCase = verifyPinUseCase
        self.isPinSetupUseCase = isPinSetupUseCase
        state = needsSetup ? .needsSetup : .idle
    }

    func setup(_ pin: String) {
        Task {
            do {
                try await changePinUseCase.execute(currentPin: nil, newPin: pin)
                state = .authenticated
            } catch {
                state = .error("Gagal menyimpan PIN")
            }
        }
    }

    func verify(_ pin: String) {
        guard state != .locked else { return }
        let isValid = verifyPinUseCase.execute(pin: pin)
        if isValid {
            attempts = 0
            state = .authenticated
        } else {
            attempts += 1
            let remaining = Self.maxAttempts - attempts
            if remaining <= 0 {
                state = .locked
                scheduleLockReset()
            } else {
                state = .wrongPIN(remaining: remaining)
            }
        }
    }

    func changePIN(current: String, new: String) {
        Task {
            do {
                try await changePinUseCase.execute(currentPin: current, newPin: new)
                state = .pinChanged
            } catch {
                state = .error("PIN lama salah")
            }
        }
    }

    private func scheduleLockReset() {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(Self.lockDuration * 1_000_000_000))
            attempts = 0
            state = .idle
        }
    }
}
