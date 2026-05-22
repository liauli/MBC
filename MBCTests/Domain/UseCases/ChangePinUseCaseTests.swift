@testable import MBC
import XCTest

final class ChangePinUseCaseTests: XCTestCase {
    private var sut: ChangePinUseCase!
    private var mockRepository: MockPINRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPINRepository()
        sut = ChangePinUseCase(repository: mockRepository)
    }

    func test_execute_firstSetup_nilCurrent_setsPin() async throws {
        // When
        try await sut.execute(currentPin: nil, newPin: "1234")

        // Then
        XCTAssertTrue(mockRepository.setPinCalled)
        XCTAssertEqual(mockRepository.storedPin, "1234")
    }

    func test_execute_changePin_correctCurrent_setsNewPin() async throws {
        // Given
        mockRepository.storedPin = "1234"

        // When
        try await sut.execute(currentPin: "1234", newPin: "5678")

        // Then
        XCTAssertEqual(mockRepository.storedPin, "5678")
    }

    func test_execute_changePin_wrongCurrent_throws() async {
        // Given
        mockRepository.storedPin = "1234"

        // When / Then
        do {
            try await sut.execute(currentPin: "0000", newPin: "5678")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .invalidName)
        }
        XCTAssertEqual(mockRepository.storedPin, "1234")
    }

    func test_execute_invalidNewPin_tooShort_throws() async {
        do {
            try await sut.execute(currentPin: nil, newPin: "12")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .invalidName)
        }
    }

    func test_execute_invalidNewPin_nonNumeric_throws() async {
        do {
            try await sut.execute(currentPin: nil, newPin: "abcd")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .invalidName)
        }
    }
}
