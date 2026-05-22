import Foundation

@MainActor
final class ViewModelProvider {
    static let instance = ViewModelProvider()

    private let useCaseProvider = UseCaseProvider.instance

    func providePINViewModel() -> PINViewModel {
        PINViewModel(
            changePinUseCase: useCaseProvider.provideChangePinUseCase(),
            verifyPinUseCase: useCaseProvider.provideVerifyPinUseCase(),
            isPinSetupUseCase: useCaseProvider.provideIsPinSetupUseCase()
        )
    }

    func provideStationViewModel() -> StationViewModel {
        StationViewModel(
            readCardUseCase: useCaseProvider.provideReadCardUseCase(),
            registerMemberUseCase: useCaseProvider.provideRegisterMemberUseCase(),
            topUpUseCase: useCaseProvider.provideTopUpUseCase()
        )
    }

    func provideGateViewModel() -> GateViewModel {
        GateViewModel(checkInUseCase: useCaseProvider.provideCheckInUseCase())
    }

    func provideTerminalViewModel() -> TerminalViewModel {
        TerminalViewModel(checkOutUseCase: useCaseProvider.provideCheckOutUseCase())
    }

    func provideScoutViewModel() -> ScoutViewModel {
        ScoutViewModel(readCardUseCase: useCaseProvider.provideReadCardUseCase())
    }
}
