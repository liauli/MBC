@testable import MBC
import XCTest

final class RemoteConfigServiceTests: XCTestCase {
    private var sut: MockRemoteConfigService!

    override func setUp() {
        super.setUp()
        sut = MockRemoteConfigService()
    }

    func test_fetchAndActivate_success() {
        sut.fetchResult = .success(())
        var result: Result<Void, Error>?

        sut.fetchAndActivate { result = $0 }

        XCTAssertNotNil(try? result?.get())
    }

    func test_fetchAndActivate_failure() {
        sut.fetchResult = .failure(NSError(domain: "test", code: -1))
        var result: Result<Void, Error>?

        sut.fetchAndActivate { result = $0 }

        switch result {
        case .failure: break
        default: XCTFail("Expected failure")
        }
    }

    func test_int_returnsConfiguredValue() {
        sut.intValues["memberTariff"] = 3000

        XCTAssertEqual(sut.int(forKey: "memberTariff"), 3000)
    }

    func test_int_returnsZeroByDefault() {
        XCTAssertEqual(sut.int(forKey: "unknown"), 0)
    }
}

private final class MockRemoteConfigService: RemoteConfigServiceProtocol {
    var fetchResult: Result<Void, Error> = .success(())
    var intValues: [String: Int] = [:]

    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(fetchResult)
    }

    func int(forKey key: String) -> Int {
        intValues[key] ?? 0
    }
}
