import Foundation

final class CardRepository: CardRepositoryProtocol {
    private let nfcService: NFCServiceProtocol
    private let cryptoService: CryptoServiceProtocol
    private let serializer: CardSerializerProtocol

    init(
        nfcService: NFCServiceProtocol,
        cryptoService: CryptoServiceProtocol,
        serializer: CardSerializerProtocol
    ) {
        self.nfcService = nfcService
        self.cryptoService = cryptoService
        self.serializer = serializer
    }

    func readCard() async throws -> MemberCard {
        let raw = try await nfcService.read()
        return try verifyAndDecrypt(raw)
    }

    func writeCard(_ card: MemberCard) async throws {
        let data = try encryptAndSign(card)
        try await nfcService.write(data)
    }

    func readAndUpdateCard(_ update: @escaping (MemberCard) throws -> MemberCard) async throws -> MemberCard {
        let cryptoService = cryptoService
        let serializer = serializer
        let outputData = try await nfcService.readAndWrite { raw in
            let card = try Self.verifyAndDecrypt(raw, crypto: cryptoService, serializer: serializer)
            let updatedCard = try update(card)
            return try Self.encryptAndSign(updatedCard, crypto: cryptoService, serializer: serializer)
        }
        return try verifyAndDecrypt(outputData)
    }

    // MARK: - HMAC + Encrypt

    private func encryptAndSign(_ card: MemberCard) throws -> Data {
        try Self.encryptAndSign(card, crypto: cryptoService, serializer: serializer)
    }

    private static func encryptAndSign(
        _ card: MemberCard,
        crypto: CryptoServiceProtocol,
        serializer: CardSerializerProtocol
    ) throws -> Data {
        let serialized = try serializer.serialize(card)
        let encrypted = try crypto.encrypt(serialized)
        let hmac = crypto.hmac(encrypted)
        return encrypted + hmac
    }

    // MARK: - Verify + Decrypt

    private func verifyAndDecrypt(_ data: Data) throws -> MemberCard {
        try Self.verifyAndDecrypt(data, crypto: cryptoService, serializer: serializer)
    }

    private static func verifyAndDecrypt(
        _ data: Data,
        crypto: CryptoServiceProtocol,
        serializer: CardSerializerProtocol
    ) throws -> MemberCard {
        let hmacSize = 32
        guard data.count > hmacSize else { throw MBCError.deserializationFailed }
        let encrypted = data.prefix(data.count - hmacSize)
        let storedHMAC = Data(data.suffix(hmacSize))
        guard crypto.verifyHMAC(encrypted, expected: storedHMAC) else {
            throw MBCError.decryptionFailed
        }
        let decrypted = try crypto.decrypt(encrypted)
        return try serializer.deserialize(decrypted)
    }
}
