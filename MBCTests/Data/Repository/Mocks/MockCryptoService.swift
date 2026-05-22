import Foundation
@testable import MBC

final class MockCryptoService: CryptoServiceProtocol {
    var encryptResult: Result<Data, Error> = .success(Data())
    var decryptResult: Result<Data, Error> = .success(Data())
    var encryptCallCount = 0
    var decryptCallCount = 0
    var hmacValid = true

    func encrypt(_ data: Data) throws -> Data {
        encryptCallCount += 1
        switch encryptResult {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }

    func decrypt(_ data: Data) throws -> Data {
        decryptCallCount += 1
        switch decryptResult {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }

    func hmac(_ data: Data) -> Data {
        Data(repeating: 0xAA, count: 32)
    }

    func verifyHMAC(_ data: Data, expected: Data) -> Bool {
        hmacValid
    }
}
