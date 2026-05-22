@testable import MBC
import XCTest

final class CryptoServiceTests: XCTestCase {
    private var sut: CryptoService!

    override func setUp() {
        super.setUp()
        sut = CryptoService()
    }

    func test_encryptDecrypt_roundtrip_returnsOriginalData() throws {
        let originalData = "MBC-Koperasi-Test-Data".data(using: .utf8)!

        let encrypted = try sut.encrypt(originalData)
        let decrypted = try sut.decrypt(encrypted)

        XCTAssertEqual(decrypted, originalData)
    }

    func test_encrypt_producesDataDifferentFromInput() throws {
        let originalData = "plaintext".data(using: .utf8)!

        let encrypted = try sut.encrypt(originalData)

        XCTAssertNotEqual(encrypted, originalData)
    }

    func test_decrypt_withTamperedData_throws() {
        let originalData = "test".data(using: .utf8)!
        guard let encrypted = try? sut.encrypt(originalData) else {
            XCTFail("Encryption failed")
            return
        }
        var tampered = encrypted
        tampered[tampered.count - 1] ^= 0xFF

        XCTAssertThrowsError(try sut.decrypt(tampered))
    }

    func test_decrypt_withInvalidData_throws() {
        let invalidData = Data([0x00, 0x01, 0x02])

        XCTAssertThrowsError(try sut.decrypt(invalidData))
    }

    func test_encryptDecrypt_emptyData_roundtrip() throws {
        let emptyData = Data()

        let encrypted = try sut.encrypt(emptyData)
        let decrypted = try sut.decrypt(encrypted)

        XCTAssertEqual(decrypted, emptyData)
    }

    // MARK: - HMAC

    func test_hmac_producesConsistentOutput() {
        let data = "test-data".data(using: .utf8)!

        let hmac1 = sut.hmac(data)
        let hmac2 = sut.hmac(data)

        XCTAssertEqual(hmac1, hmac2)
        XCTAssertEqual(hmac1.count, 32)
    }

    func test_verifyHMAC_validData_returnsTrue() {
        let data = "test-data".data(using: .utf8)!
        let hmac = sut.hmac(data)

        XCTAssertTrue(sut.verifyHMAC(data, expected: hmac))
    }

    func test_verifyHMAC_tamperedData_returnsFalse() {
        let data = "test-data".data(using: .utf8)!
        let hmac = sut.hmac(data)
        let tampered = "tampered".data(using: .utf8)!

        XCTAssertFalse(sut.verifyHMAC(tampered, expected: hmac))
    }
}
