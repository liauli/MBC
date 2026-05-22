import Foundation

final class UseCaseProvider {
    static let instance = UseCaseProvider()

    private let repositoryProvider = RepositoryProvider.instance

    func provideCheckInUseCase() -> CheckInUseCaseProtocol {
        CheckInUseCase(cardRepository: repositoryProvider.provideCardRepository())
    }

    func provideCheckOutUseCase() -> CheckOutUseCaseProtocol {
        CheckOutUseCase(cardRepository: repositoryProvider.provideCardRepository())
    }

    func provideReadCardUseCase() -> ReadCardUseCaseProtocol {
        ReadCardUseCase(repository: repositoryProvider.provideCardRepository())
    }

    func provideRegisterMemberUseCase() -> RegisterMemberUseCaseProtocol {
        RegisterMemberUseCase(repository: repositoryProvider.provideCardRepository())
    }

    func provideTopUpUseCase() -> TopUpUseCaseProtocol {
        TopUpUseCase(repository: repositoryProvider.provideCardRepository())
    }

    func provideChangePinUseCase() -> ChangePinUseCaseProtocol {
        ChangePinUseCase(repository: repositoryProvider.providePINRepository())
    }

    func provideVerifyPinUseCase() -> VerifyPinUseCaseProtocol {
        VerifyPinUseCase(repository: repositoryProvider.providePINRepository())
    }

    func provideIsPinSetupUseCase() -> IsPinSetupUseCaseProtocol {
        IsPinSetupUseCase(repository: repositoryProvider.providePINRepository())
    }
}
