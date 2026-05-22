@testable import MBC
import XCTest

final class RemoteConfigServiceTests: XCTestCase {
    private var sut: MockRemoteConfigService!

    override func setUp() {
        super.setUp()
        sut = MockRemoteConfigService()
    }

    func test_fetchAndActivate_success_callsCompletion() {
        // Given
        sut.fetchResult = .success(())
        var result: Result<Void, Error>?

        // When
        sut.fetchAndActivate { result = $0 }

        // Then
        XCTAssertNotNil(try? result?.get())
    }

    func test_fetchAndActivate_failure_returnsError() {
        // Given
        sut.fetchResult = .failure(NSError(domain: "test", code: -1))
        var result: Result<Void, Error>?

        // When
        sut.fetchAndActivate { result = $0 }

        // Then
        switch result {
        case .failure:
            break
        default:
            XCTFail("Expected failure")
        }
    }

    func test_string_returnsConfiguredValue() {
        // Given
        sut.stringValues["feature_flag"] = "enabled"

        // When
        let value = sut.string(forKey: "feature_flag")

        // Then
        XCTAssertEqual(value, "enabled")
    }

    func test_bool_returnsConfiguredValue() {
        // Given
        sut.boolValues["is_enabled"] = true

        // When
        let value = sut.bool(forKey: "is_enabled")

        // Then
        XCTAssertTrue(value)
    }

    func test_int_returnsConfiguredValue() {
        // Given
        sut.intValues["max_retry"] = 3

        // When
        let value = sut.int(forKey: "max_retry")

        // Then
        XCTAssertEqual(value, 3)
    }
}

// MARK: - Mock

private final class MockRemoteConfigService: RemoteConfigServiceProtocol {
    var fetchResult: Result<Void, Error> = .success(())
    var stringValues: [String: String] = [:]
    var boolValues: [String: Bool] = [:]
    var intValues: [String: Int] = [:]

    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(fetchResult)
    }

    func string(forKey key: String) -> String {
        stringValues[key] ?? ""
    }

    func bool(forKey key: String) -> Bool {
        boolValues[key] ?? false
    }

    func int(forKey key: String) -> Int {
        intValues[key] ?? 0
    }
}
