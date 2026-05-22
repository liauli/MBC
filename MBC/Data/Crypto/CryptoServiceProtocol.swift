import Foundation

protocol CryptoServiceProtocol {
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
    func hmac(_ data: Data) -> Data
    func verifyHMAC(_ data: Data, expected: Data) -> Bool
}
