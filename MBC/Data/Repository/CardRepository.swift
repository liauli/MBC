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
        let encryptedData = try await nfcService.read()
        return try decryptAndDeserialize(encryptedData)
    }

    func writeCard(_ card: MemberCard) async throws {
        let data = try serializeAndEncrypt(card)
        try await nfcService.write(data)
    }

    func readAndUpdateCard(_ update: @escaping (MemberCard) throws -> MemberCard) async throws -> MemberCard {
        let outputData = try await nfcService.readAndWrite { [self] encryptedData in
            let card = try decryptAndDeserialize(encryptedData)
            let updatedCard = try update(card)
            return try serializeAndEncrypt(updatedCard)
        }
        return try decryptAndDeserialize(outputData)
    }

    private func decryptAndDeserialize(_ data: Data) throws -> MemberCard {
        let decrypted = try cryptoService.decrypt(data)
        return try serializer.deserialize(decrypted)
    }

    private func serializeAndEncrypt(_ card: MemberCard) throws -> Data {
        let serialized = try serializer.serialize(card)
        return try cryptoService.encrypt(serialized)
    }
}
