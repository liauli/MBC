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

    func readCard(completion: @escaping (Result<MemberCard, MBCError>) -> Void) {
        nfcService.read { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(encryptedData):
                completion(decryptAndDeserialize(encryptedData))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func writeCard(_ card: MemberCard, completion: @escaping (Result<Void, MBCError>) -> Void) {
        let data: Data
        do {
            data = try serializeAndEncrypt(card)
        } catch let error as MBCError {
            completion(.failure(error))
            return
        } catch {
            completion(.failure(.serializationFailed))
            return
        }
        nfcService.write(data, completion: completion)
    }

    func readAndUpdateCard(
        _ update: @escaping (MemberCard) throws -> MemberCard,
        completion: @escaping (Result<MemberCard, MBCError>) -> Void
    ) {
        nfcService.read { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(encryptedData):
                let cardResult = decryptAndDeserialize(encryptedData)
                switch cardResult {
                case let .success(card):
                    do {
                        let updatedCard = try update(card)
                        let data = try serializeAndEncrypt(updatedCard)
                        nfcService.write(data) { writeResult in
                            switch writeResult {
                            case .success:
                                completion(.success(updatedCard))
                            case let .failure(error):
                                completion(.failure(error))
                            }
                        }
                    } catch let error as MBCError {
                        completion(.failure(error))
                    } catch {
                        completion(.failure(.serializationFailed))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private

    private func decryptAndDeserialize(_ data: Data) -> Result<MemberCard, MBCError> {
        do {
            let decrypted = try cryptoService.decrypt(data)
            let card = try serializer.deserialize(decrypted)
            return .success(card)
        } catch let error as MBCError {
            return .failure(error)
        } catch {
            return .failure(.decryptionFailed)
        }
    }

    private func serializeAndEncrypt(_ card: MemberCard) throws -> Data {
        let serialized = try serializer.serialize(card)
        return try cryptoService.encrypt(serialized)
    }
}
