@testable import MBC
import XCTest

final class CardRepositoryTests: XCTestCase {
    private var sut: CardRepository!
    private var mockNFC: MockNFCService!
    private var mockCrypto: MockCryptoService!
    private var mockSerializer: MockCardSerializer!

    override func setUp() {
        super.setUp()
        mockNFC = MockNFCService()
        mockCrypto = MockCryptoService()
        mockSerializer = MockCardSerializer()
        sut = CardRepository(
            nfcService: mockNFC,
            cryptoService: mockCrypto,
            serializer: mockSerializer
        )
    }

    // MARK: - readCard

    func test_readCard_success_returnsDeserializedCard() {
        // Given
        let expectedCard = makeTestCard()
        let encryptedData = Data("encrypted".utf8)
        let decryptedData = Data("decrypted".utf8)
        mockNFC.readResult = .success(encryptedData)
        mockCrypto.decryptResult = .success(decryptedData)
        mockSerializer.deserializeResult = .success(expectedCard)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.readCard { result = $0 }

        // Then
        XCTAssertEqual(result, .success(expectedCard))
        XCTAssertEqual(mockNFC.readCallCount, 1)
        XCTAssertEqual(mockCrypto.decryptCallCount, 1)
        XCTAssertEqual(mockSerializer.deserializeCallCount, 1)
    }

    func test_readCard_nfcFails_returnsNFCError() {
        // Given
        mockNFC.readResult = .failure(.nfcReadFailed)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.readCard { result = $0 }

        // Then
        XCTAssertEqual(result, .failure(.nfcReadFailed))
        XCTAssertEqual(mockCrypto.decryptCallCount, 0)
    }

    func test_readCard_decryptionFails_returnsDecryptionError() {
        // Given
        mockNFC.readResult = .success(Data("data".utf8))
        mockCrypto.decryptResult = .failure(MBCError.decryptionFailed)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.readCard { result = $0 }

        // Then
        XCTAssertEqual(result, .failure(.decryptionFailed))
    }

    func test_readCard_deserializationFails_returnsDeserializationError() {
        // Given
        mockNFC.readResult = .success(Data("data".utf8))
        mockCrypto.decryptResult = .success(Data("decrypted".utf8))
        mockSerializer.deserializeResult = .failure(MBCError.deserializationFailed)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.readCard { result = $0 }

        // Then
        XCTAssertEqual(result, .failure(.deserializationFailed))
    }

    // MARK: - writeCard

    func test_writeCard_success_writesEncryptedData() {
        // Given
        let card = makeTestCard()
        let serializedData = Data("serialized".utf8)
        let encryptedData = Data("encrypted".utf8)
        mockSerializer.serializeResult = .success(serializedData)
        mockCrypto.encryptResult = .success(encryptedData)
        mockNFC.writeResult = .success(())

        // When
        var result: Result<Void, MBCError>?
        sut.writeCard(card) { result = $0 }

        // Then
        switch result {
        case .success: break
        default: XCTFail("Expected success")
        }
        XCTAssertEqual(mockNFC.writtenData, encryptedData)
        XCTAssertEqual(mockSerializer.serializeCallCount, 1)
        XCTAssertEqual(mockCrypto.encryptCallCount, 1)
        XCTAssertEqual(mockNFC.writeCallCount, 1)
    }

    func test_writeCard_serializationFails_returnsError() {
        // Given
        let card = makeTestCard()
        mockSerializer.serializeResult = .failure(MBCError.serializationFailed)

        // When
        var error: MBCError?
        sut.writeCard(card) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .serializationFailed)
        XCTAssertEqual(mockNFC.writeCallCount, 0)
    }

    func test_writeCard_encryptionFails_returnsError() {
        // Given
        let card = makeTestCard()
        mockSerializer.serializeResult = .success(Data("serialized".utf8))
        mockCrypto.encryptResult = .failure(MBCError.encryptionFailed)

        // When
        var error: MBCError?
        sut.writeCard(card) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .encryptionFailed)
        XCTAssertEqual(mockNFC.writeCallCount, 0)
    }

    func test_writeCard_nfcWriteFails_returnsNFCError() {
        // Given
        let card = makeTestCard()
        mockSerializer.serializeResult = .success(Data("serialized".utf8))
        mockCrypto.encryptResult = .success(Data("encrypted".utf8))
        mockNFC.writeResult = .failure(.nfcWriteFailed)

        // When
        var error: MBCError?
        sut.writeCard(card) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .nfcWriteFailed)
    }

    // MARK: - readAndUpdateCard

    func test_readAndUpdateCard_success_returnsUpdatedCard() {
        // Given
        let originalCard = makeTestCard()
        var updatedCard = originalCard
        updatedCard.wallet = Wallet(balance: 100_000, lastTopUpAmount: 50000)

        let encryptedData = Data("encrypted".utf8)
        let decryptedData = Data("decrypted".utf8)
        let reserializedData = Data("reserialized".utf8)
        let reencryptedData = Data("reencrypted".utf8)

        mockNFC.readResult = .success(encryptedData)
        mockCrypto.decryptResult = .success(decryptedData)
        mockSerializer.deserializeResult = .success(originalCard)
        mockSerializer.serializeResult = .success(reserializedData)
        mockCrypto.encryptResult = .success(reencryptedData)
        mockNFC.writeResult = .success(())

        // When
        var result: Result<MemberCard, MBCError>?
        sut.readAndUpdateCard({ card in
            var card = card
            card.wallet = Wallet(balance: 100_000, lastTopUpAmount: 50000)
            return card
        }, completion: { result = $0 })

        // Then
        XCTAssertEqual(result, .success(updatedCard))
        XCTAssertEqual(mockNFC.readCallCount, 1)
        XCTAssertEqual(mockNFC.writeCallCount, 1)
        XCTAssertEqual(mockNFC.writtenData, reencryptedData)
    }

    func test_readAndUpdateCard_updateThrows_returnsError() {
        // Given
        let originalCard = makeTestCard()
        mockNFC.readResult = .success(Data("encrypted".utf8))
        mockCrypto.decryptResult = .success(Data("decrypted".utf8))
        mockSerializer.deserializeResult = .success(originalCard)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.readAndUpdateCard({ _ in
            throw MBCError.insufficientBalance(required: 5000, available: 1000)
        }, completion: { result = $0 })

        // Then
        XCTAssertEqual(result, .failure(.insufficientBalance(required: 5000, available: 1000)))
        XCTAssertEqual(mockNFC.writeCallCount, 0)
    }

    func test_readAndUpdateCard_nfcReadFails_returnsError() {
        // Given
        mockNFC.readResult = .failure(.nfcReadFailed)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.readAndUpdateCard({ $0 }, completion: { result = $0 })

        // Then
        XCTAssertEqual(result, .failure(.nfcReadFailed))
        XCTAssertEqual(mockNFC.writeCallCount, 0)
    }

    func test_readAndUpdateCard_writeFails_returnsWriteError() {
        // Given
        let card = makeTestCard()
        mockNFC.readResult = .success(Data("encrypted".utf8))
        mockCrypto.decryptResult = .success(Data("decrypted".utf8))
        mockSerializer.deserializeResult = .success(card)
        mockSerializer.serializeResult = .success(Data("serialized".utf8))
        mockCrypto.encryptResult = .success(Data("reencrypted".utf8))
        mockNFC.writeResult = .failure(.nfcWriteFailed)

        // When
        var result: Result<MemberCard, MBCError>?
        sut.readAndUpdateCard({ $0 }, completion: { result = $0 })

        // Then
        XCTAssertEqual(result, .failure(.nfcWriteFailed))
    }

    // MARK: - Helpers

    private func makeTestCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(
                memberID: "MBC-0001",
                name: "Ahmad Sudirman",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .idle,
            transactions: [],
            writeCounter: 1
        )
    }
}
