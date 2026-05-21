import CryptoKit
import Foundation

final class CryptoService: CryptoServiceProtocol {
    private let key: SymmetricKey

    init(key: SymmetricKey = CryptoService.defaultKey) {
        self.key = key
    }

    func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }
        return combined
    }

    func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    private static var defaultKey: SymmetricKey {
        let seed: [UInt8] = [
            0x4D, 0x42, 0x43, 0x2D, 0x4B, 0x6F, 0x70, 0x65,
            0x72, 0x61, 0x73, 0x69, 0x2D, 0x44, 0x65, 0x73,
            0x61, 0x2D, 0x32, 0x30, 0x32, 0x36, 0x2D, 0x4B,
            0x65, 0x79, 0x2D, 0x53, 0x65, 0x65, 0x64, 0x21,
        ]
        return SymmetricKey(data: Data(seed))
    }
}
