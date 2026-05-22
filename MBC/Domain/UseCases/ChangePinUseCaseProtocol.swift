import Foundation

protocol ChangePinUseCaseProtocol {
    func execute(currentPin: String?, newPin: String, completion: @escaping (Result<Void, MBCError>) -> Void)
}
