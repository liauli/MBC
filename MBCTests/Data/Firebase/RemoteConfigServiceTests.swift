@testable import MBC
import XCTest

final class RemoteConfigServiceTests: XCTestCase {
    private var sut: MockRemoteConfigService!

    override func setUp() {
        super.setUp()
        sut = MockRemoteConfigService()
    }

    func test_fetchAndActivate_success_callsCompletion() {
        sut.fetchResult = .success(())
        var result: Result<Void, Error>?

        sut.fetchAndActivate { result = $0 }

        XCTAssertNotNil(try? result?.get())
    }

    func test_fetchAndActivate_failure_returnsError() {
        sut.fetchResult = .failure(NSError(domain: "test", code: -1))
        var result: Result<Void, Error>?

        sut.fetchAndActivate { result = $0 }

        switch result {
        case .failure:
            break
        default:
            XCTFail("Expected failure")
        }
    }

    func test_bool_returnsConfiguredValue() {
        sut.boolValues["is_enabled"] = true

        XCTAssertTrue(sut.bool(forKey: "is_enabled"))
    }

    func test_bool_returnsFalseByDefault() {
        XCTAssertFalse(sut.bool(forKey: "unknown_key"))
    }
}

// MARK: - Mock

private final class MockRemoteConfigService: RemoteConfigServiceProtocol {
    var fetchResult: Result<Void, Error> = .success(())
    var boolValues: [String: Bool] = [:]

    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(fetchResult)
    }

    func bool(forKey key: String) -> Bool {
        boolValues[key] ?? false
    }
}
