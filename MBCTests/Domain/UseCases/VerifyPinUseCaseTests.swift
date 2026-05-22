@testable import MBC
import XCTest

final class VerifyPinUseCaseTests: XCTestCase {
    private var sut: VerifyPinUseCase!
    private var mockRepository: MockPINRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPINRepository()
        sut = VerifyPinUseCase(repository: mockRepository)
    }

    func test_execute_correctPin_returnsTrue() {
        // Given
        mockRepository.storedPin = "1234"

        // When / Then
        XCTAssertTrue(sut.execute(pin: "1234"))
    }

    func test_execute_wrongPin_returnsFalse() {
        // Given
        mockRepository.storedPin = "1234"

        // When / Then
        XCTAssertFalse(sut.execute(pin: "0000"))
    }

    func test_execute_noPinSet_returnsFalse() {
        // When / Then
        XCTAssertFalse(sut.execute(pin: "1234"))
    }
}
