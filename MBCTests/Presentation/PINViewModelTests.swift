@testable import MBC
import XCTest

@MainActor
final class PINViewModelTests: XCTestCase {
    private var sut: PINViewModel!
    private var mockChangePin: MockChangePinUseCase!
    private var mockVerifyPin: MockVerifyPinUseCase!
    private var mockIsPinSetup: MockIsPinSetupUseCase!

    override func setUp() {
        super.setUp()
        mockChangePin = MockChangePinUseCase()
        mockVerifyPin = MockVerifyPinUseCase()
        mockIsPinSetup = MockIsPinSetupUseCase()
    }

    func test_init_noPinSet_needsSetup() {
        // Given
        mockIsPinSetup.isSetup = false
        sut = makeSUT()

        // Then
        XCTAssertEqual(sut.state, .needsSetup)
    }

    func test_init_pinSet_idle() {
        // Given
        mockIsPinSetup.isSetup = true
        sut = makeSUT()

        // Then
        XCTAssertEqual(sut.state, .idle)
    }

    func test_verify_correctPin_authenticated() {
        // Given
        mockIsPinSetup.isSetup = true
        mockVerifyPin.storedPin = "1234"
        sut = makeSUT()

        // When
        sut.verify("1234")

        // Then
        XCTAssertEqual(sut.state, .authenticated)
    }

    func test_verify_wrongPin_showsRemaining() {
        // Given
        mockIsPinSetup.isSetup = true
        mockVerifyPin.storedPin = "1234"
        sut = makeSUT()

        // When
        sut.verify("0000")

        // Then
        XCTAssertEqual(sut.state, .wrongPIN(remaining: 2))
    }

    func test_verify_threeWrongAttempts_locks() {
        // Given
        mockIsPinSetup.isSetup = true
        mockVerifyPin.storedPin = "1234"
        sut = makeSUT()

        // When
        sut.verify("0000")
        sut.verify("0000")
        sut.verify("0000")

        // Then
        XCTAssertEqual(sut.state, .locked)
    }

    func test_setup_success_authenticated() async throws {
        // Given
        mockIsPinSetup.isSetup = false
        sut = makeSUT()

        // When
        sut.setup("1234")
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.state, .authenticated)
    }

    private func makeSUT() -> PINViewModel {
        PINViewModel(
            changePinUseCase: mockChangePin,
            verifyPinUseCase: mockVerifyPin,
            isPinSetupUseCase: mockIsPinSetup
        )
    }
}
