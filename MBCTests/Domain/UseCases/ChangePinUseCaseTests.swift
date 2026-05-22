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

    func test_execute_firstSetup_nilCurrent_setsPin() {
        // When
        var result: Result<Void, MBCError>?
        sut.execute(currentPin: nil, newPin: "1234") { result = $0 }

        // Then
        switch result {
        case .success: break
        default: XCTFail("Expected success")
        }
        XCTAssertTrue(mockRepository.setPinCalled)
        XCTAssertEqual(mockRepository.storedPin, "1234")
    }

    func test_execute_changePin_correctCurrent_setsNewPin() {
        // Given
        mockRepository.storedPin = "1234"

        // When
        var result: Result<Void, MBCError>?
        sut.execute(currentPin: "1234", newPin: "5678") { result = $0 }

        // Then
        switch result {
        case .success: break
        default: XCTFail("Expected success")
        }
        XCTAssertEqual(mockRepository.storedPin, "5678")
    }

    func test_execute_changePin_wrongCurrent_fails() {
        // Given
        mockRepository.storedPin = "1234"

        // When
        var error: MBCError?
        sut.execute(currentPin: "0000", newPin: "5678") { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidName)
        XCTAssertEqual(mockRepository.storedPin, "1234")
    }

    func test_execute_invalidNewPin_tooShort_fails() {
        // When
        var error: MBCError?
        sut.execute(currentPin: nil, newPin: "12") { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidName)
    }

    func test_execute_invalidNewPin_nonNumeric_fails() {
        // When
        var error: MBCError?
        sut.execute(currentPin: nil, newPin: "abcd") { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidName)
    }
}
