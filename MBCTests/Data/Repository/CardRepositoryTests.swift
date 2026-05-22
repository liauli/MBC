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

    func test_readCard_success_returnsDeserializedCard() async throws {
        // Given
        let expectedCard = makeTestCard()
        mockNFC.readResult = .success(Data("encrypted".utf8))
        mockCrypto.decryptResult = .success(Data("decrypted".utf8))
        mockSerializer.deserializeResult = .success(expectedCard)

        // When
        let result = try await sut.readCard()

        // Then
        XCTAssertEqual(result, expectedCard)
        XCTAssertEqual(mockNFC.readCallCount, 1)
        XCTAssertEqual(mockCrypto.decryptCallCount, 1)
        XCTAssertEqual(mockSerializer.deserializeCallCount, 1)
    }

    func test_readCard_nfcFails_throws() async {
        // Given
        mockNFC.readResult = .failure(.nfcReadFailed)

        // When / Then
        do {
            _ = try await sut.readCard()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .nfcReadFailed)
        }
        XCTAssertEqual(mockCrypto.decryptCallCount, 0)
    }

    func test_readCard_decryptionFails_throws() async {
        // Given
        mockNFC.readResult = .success(Data("data".utf8))
        mockCrypto.decryptResult = .failure(MBCError.decryptionFailed)

        // When / Then
        do {
            _ = try await sut.readCard()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .decryptionFailed)
        }
    }

    func test_readCard_deserializationFails_throws() async {
        // Given
        mockNFC.readResult = .success(Data("data".utf8))
        mockCrypto.decryptResult = .success(Data("decrypted".utf8))
        mockSerializer.deserializeResult = .failure(MBCError.deserializationFailed)

        // When / Then
        do {
            _ = try await sut.readCard()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .deserializationFailed)
        }
    }

    // MARK: - writeCard

    func test_writeCard_success_writesEncryptedData() async throws {
        // Given
        let card = makeTestCard()
        let encryptedData = Data("encrypted".utf8)
        mockSerializer.serializeResult = .success(Data("serialized".utf8))
        mockCrypto.encryptResult = .success(encryptedData)
        mockNFC.writeResult = .success(())

        // When
        try await sut.writeCard(card)

        // Then
        XCTAssertEqual(mockNFC.writtenData, encryptedData)
        XCTAssertEqual(mockSerializer.serializeCallCount, 1)
        XCTAssertEqual(mockCrypto.encryptCallCount, 1)
        XCTAssertEqual(mockNFC.writeCallCount, 1)
    }

    func test_writeCard_serializationFails_throws() async {
        // Given
        mockSerializer.serializeResult = .failure(MBCError.serializationFailed)

        // When / Then
        do {
            try await sut.writeCard(makeTestCard())
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .serializationFailed)
        }
        XCTAssertEqual(mockNFC.writeCallCount, 0)
    }

    func test_writeCard_nfcWriteFails_throws() async {
        // Given
        mockSerializer.serializeResult = .success(Data("serialized".utf8))
        mockCrypto.encryptResult = .success(Data("encrypted".utf8))
        mockNFC.writeResult = .failure(.nfcWriteFailed)

        // When / Then
        do {
            try await sut.writeCard(makeTestCard())
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .nfcWriteFailed)
        }
    }

    // MARK: - readAndUpdateCard

    func test_readAndUpdateCard_success_returnsUpdatedCard() async throws {
        // Given
        let originalCard = makeTestCard()
        mockNFC.readResult = .success(Data("encrypted".utf8))
        mockCrypto.decryptResult = .success(Data("decrypted".utf8))
        mockSerializer.deserializeResult = .success(originalCard)
        mockSerializer.serializeResult = .success(Data("reserialized".utf8))
        mockCrypto.encryptResult = .success(Data("reencrypted".utf8))
        mockNFC.writeResult = .success(())

        // When
        let result = try await sut.readAndUpdateCard { card in
            var card = card
            card.wallet = Wallet(balance: 100_000, lastTopUpAmount: 50000)
            return card
        }

        // Then
        XCTAssertEqual(result.wallet.balance, 100_000)
        XCTAssertEqual(mockNFC.readCallCount, 1)
        XCTAssertEqual(mockNFC.writeCallCount, 1)
    }

    func test_readAndUpdateCard_updateThrows_throws() async {
        // Given
        mockNFC.readResult = .success(Data("encrypted".utf8))
        mockCrypto.decryptResult = .success(Data("decrypted".utf8))
        mockSerializer.deserializeResult = .success(makeTestCard())

        // When / Then
        do {
            _ = try await sut.readAndUpdateCard { _ in
                throw MBCError.insufficientBalance(required: 5000, available: 1000)
            }
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .insufficientBalance(required: 5000, available: 1000))
        }
        XCTAssertEqual(mockNFC.writeCallCount, 0)
    }

    func test_readAndUpdateCard_nfcReadFails_throws() async {
        // Given
        mockNFC.readResult = .failure(.nfcReadFailed)

        // When / Then
        do {
            _ = try await sut.readAndUpdateCard { $0 }
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .nfcReadFailed)
        }
        XCTAssertEqual(mockNFC.writeCallCount, 0)
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
