@testable import MBC
import XCTest

final class CrashlyticsServiceTests: XCTestCase {
    private var sut: MockCrashlyticsService!

    override func setUp() {
        super.setUp()
        sut = MockCrashlyticsService()
    }

    func test_logNonFatal_recordsError() {
        // Given
        let error = NSError(domain: "test", code: 42)

        // When
        sut.logNonFatal(error)

        // Then
        XCTAssertEqual(sut.recordedErrors.count, 1)
        XCTAssertEqual((sut.recordedErrors.first as? NSError)?.code, 42)
    }

    func test_log_recordsMessage() {
        // Given
        let message = "Something happened"

        // When
        sut.log(message)

        // Then
        XCTAssertEqual(sut.loggedMessages, [message])
    }

    func test_setUserID_storesID() {
        // Given
        let userID = "user-123"

        // When
        sut.setUserID(userID)

        // Then
        XCTAssertEqual(sut.currentUserID, userID)
    }
}

// MARK: - Mock

private final class MockCrashlyticsService: CrashlyticsServiceProtocol {
    var recordedErrors: [Error] = []
    var loggedMessages: [String] = []
    var currentUserID: String?

    func logNonFatal(_ error: Error) {
        recordedErrors.append(error)
    }

    func log(_ message: String) {
        loggedMessages.append(message)
    }

    func setUserID(_ id: String) {
        currentUserID = id
    }
}
