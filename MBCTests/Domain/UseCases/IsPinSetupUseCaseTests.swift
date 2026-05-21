@testable import MBC
import XCTest

final class IsPinSetupUseCaseTests: XCTestCase {
    private var sut: IsPinSetupUseCase!
    private var mockRepository: MockPINRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPINRepository()
        sut = IsPinSetupUseCase(repository: mockRepository)
    }

    func test_execute_pinSet_returnsTrue() {
        // Given
        mockRepository.storedPin = "1234"

        // When / Then
        XCTAssertTrue(sut.execute())
    }

    func test_execute_noPinSet_returnsFalse() {
        // When / Then
        XCTAssertFalse(sut.execute())
    }
}
