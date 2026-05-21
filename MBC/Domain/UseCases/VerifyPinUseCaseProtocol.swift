import Foundation

protocol VerifyPinUseCaseProtocol {
    func execute(pin: String) -> Bool
}
