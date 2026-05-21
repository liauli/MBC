@testable import MBC
import XCTest

final class PINRepositoryTests: XCTestCase {
    private var sut: PINRepository!
    private var mockKeychain: MockKeychainWrapper!

    override func setUp() {
        super.setUp()
        mockKeychain = MockKeychainWrapper()
        sut = PINRepository(keychain: mockKeychain)
    }

    // MARK: - setPin

    func test_setPin_savesToKeychain() {
        // When
        let result = sut.setPin("1234")

        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(mockKeychain.saveCalled)
    }

    func test_setPin_storesCorrectData() {
        // When
        _ = sut.setPin("5678")

        // Then
        let stored = mockKeychain.storage["mbc.user.pin"]
        XCTAssertEqual(stored, Data("5678".utf8))
    }

    // MARK: - verifyPin

    func test_verifyPin_correctPin_returnsTrue() {
        // Given
        _ = sut.setPin("1234")

        // When
        let result = sut.verifyPin("1234")

        // Then
        XCTAssertTrue(result)
    }

    func test_verifyPin_wrongPin_returnsFalse() {
        // Given
        _ = sut.setPin("1234")

        // When
        let result = sut.verifyPin("0000")

        // Then
        XCTAssertFalse(result)
    }

    func test_verifyPin_noPinSet_returnsFalse() {
        // When
        let result = sut.verifyPin("1234")

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - isPinSet

    func test_isPinSet_noPinStored_returnsFalse() {
        // When
        let result = sut.isPinSet()

        // Then
        XCTAssertFalse(result)
    }

    func test_isPinSet_pinStored_returnsTrue() {
        // Given
        _ = sut.setPin("1234")

        // When
        let result = sut.isPinSet()

        // Then
        XCTAssertTrue(result)
    }
}
