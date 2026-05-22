import CryptoKit
import Foundation

final class CryptoService: CryptoServiceProtocol {
    private var key: SymmetricKey {
        let part1: [UInt8] = [
            0xA3, 0x7F, 0x1B, 0xC4, 0x9E, 0x52, 0xD8, 0x6A,
            0xF1, 0x3D, 0x84, 0xB7, 0x2C, 0xE9, 0x56, 0x0F,
            0x73, 0xAB, 0x48, 0xDE, 0x91, 0x65, 0xC2, 0x37,
            0x8A, 0xF4, 0x1E, 0xD0, 0x59, 0xBC, 0x26, 0x7D,
        ]
        let part2: [UInt8] = [
            0xD1, 0x4E, 0x82, 0xA9, 0xF3, 0x67, 0x1C, 0xB5,
            0x28, 0x9A, 0xE6, 0x43, 0x7F, 0xD2, 0x0B, 0x64,
            0xAC, 0x39, 0xF7, 0x5E, 0xC1, 0x86, 0x4D, 0xEB,
            0x10, 0x73, 0xA8, 0x5F, 0x2E, 0x94, 0xD6, 0x41,
        ]
        let raw = zip(part1, part2).map { $0 ^ $1 }
        return SymmetricKey(data: Data(raw))
    }

    func encrypt(_ data: Data) throws -> Data {
        guard let sealed = try? AES.GCM.seal(data, using: key),
              let combined = sealed.combined
        else {
            throw MBCError.encryptionFailed
        }
        return combined
    }

    func decrypt(_ data: Data) throws -> Data {
        guard let box = try? AES.GCM.SealedBox(combined: data),
              let decrypted = try? AES.GCM.open(box, using: key)
        else {
            throw MBCError.decryptionFailed
        }
        return decrypted
    }

    func hmac(_ data: Data) -> Data {
        let auth = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(auth)
    }

    func verifyHMAC(_ data: Data, expected: Data) -> Bool {
        hmac(data) == expected
    }
}
