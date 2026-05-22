import Foundation

protocol ChangePinUseCaseProtocol {
    func execute(currentPin: String?, newPin: String) async throws
}
