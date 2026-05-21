@testable import MBC
import XCTest

final class CryptoServiceTests: XCTestCase {
    private var sut: CryptoService!

    override func setUp() {
        super.setUp()
        sut = CryptoService()
    }

    func test_encryptDecrypt_roundtrip_returnsOriginalData() throws {
        // Given
        let originalData = "MBC-Koperasi-Test-Data".data(using: .utf8)!

        // When
        let encrypted = try sut.encrypt(originalData)
        let decrypted = try sut.decrypt(encrypted)

        // Then
        XCTAssertEqual(decrypted, originalData)
    }

    func test_encrypt_producesDataDifferentFromInput() throws {
        // Given
        let originalData = "plaintext".data(using: .utf8)!

        // When
        let encrypted = try sut.encrypt(originalData)

        // Then
        XCTAssertNotEqual(encrypted, originalData)
    }

    func test_decrypt_withTamperedData_throws() {
        // Given
        let originalData = "test".data(using: .utf8)!
        guard let encrypted = try? sut.encrypt(originalData) else {
            XCTFail("Encryption failed")
            return
        }
        var tampered = encrypted
        tampered[tampered.count - 1] ^= 0xFF

        // When / Then
        XCTAssertThrowsError(try sut.decrypt(tampered))
    }

    func test_decrypt_withInvalidData_throws() {
        // Given
        let invalidData = Data([0x00, 0x01, 0x02])

        // When / Then
        XCTAssertThrowsError(try sut.decrypt(invalidData))
    }

    func test_encryptDecrypt_emptyData_roundtrip() throws {
        // Given
        let emptyData = Data()

        // When
        let encrypted = try sut.encrypt(emptyData)
        let decrypted = try sut.decrypt(encrypted)

        // Then
        XCTAssertEqual(decrypted, emptyData)
    }
}
