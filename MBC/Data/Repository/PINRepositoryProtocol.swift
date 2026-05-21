import Foundation

protocol PINRepositoryProtocol {
    func setPin(_ pin: String) -> Bool
    func verifyPin(_ pin: String) -> Bool
    func isPinSet() -> Bool
}
