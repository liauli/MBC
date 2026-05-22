import Foundation
@testable import MBC

final class MockCheckInUseCase: CheckInUseCaseProtocol {
    var result: Result<MemberCard, MBCError> = .failure(.nfcReadFailed)

    func execute(simulatedTime: Date?) async throws -> MemberCard {
        switch result {
        case let .success(card): return card
        case let .failure(error): throw error
        }
    }
}

final class MockCheckOutUseCase: CheckOutUseCaseProtocol {
    var result: Result<(MemberCard, TariffResult), MBCError> = .failure(.nfcReadFailed)

    func execute() async throws -> (MemberCard, TariffResult) {
        switch result {
        case let .success(value): return value
        case let .failure(error): throw error
        }
    }
}

final class MockReadCardUseCase: ReadCardUseCaseProtocol {
    var result: Result<MemberCard, MBCError> = .failure(.nfcReadFailed)

    func execute() async throws -> MemberCard {
        switch result {
        case let .success(card): return card
        case let .failure(error): throw error
        }
    }
}

final class MockRegisterMemberUseCase: RegisterMemberUseCaseProtocol {
    var result: Result<MemberCard, MBCError> = .failure(.nfcWriteFailed)

    func execute(name: String) async throws -> MemberCard {
        switch result {
        case let .success(card): return card
        case let .failure(error): throw error
        }
    }
}

final class MockTopUpUseCase: TopUpUseCaseProtocol {
    var result: Result<MemberCard, MBCError> = .failure(.nfcWriteFailed)

    func execute(amount: Int) async throws -> MemberCard {
        switch result {
        case let .success(card): return card
        case let .failure(error): throw error
        }
    }
}

final class MockChangePinUseCase: ChangePinUseCaseProtocol {
    var shouldSucceed = true

    func execute(currentPin: String?, newPin: String) async throws {
        guard shouldSucceed else { throw MBCError.invalidName }
    }
}

final class MockVerifyPinUseCase: VerifyPinUseCaseProtocol {
    var storedPin: String?

    func execute(pin: String) -> Bool {
        pin == storedPin
    }
}

final class MockIsPinSetupUseCase: IsPinSetupUseCaseProtocol {
    var isSetup = false

    func execute() -> Bool {
        isSetup
    }
}
