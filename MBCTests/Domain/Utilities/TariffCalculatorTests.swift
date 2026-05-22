@testable import MBC
import XCTest

final class TariffCalculatorTests: XCTestCase {
    func test_calculate_exactOneHour_returns2000() {
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_003_600)

        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut, remoteConfig: nil)

        XCTAssertEqual(result, TariffResult(duration: 3600, hours: 1, amount: 2000))
    }

    func test_calculate_oneSecondOverHour_roundsUp() {
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_003_601)

        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut, remoteConfig: nil)

        XCTAssertEqual(result.hours, 2)
        XCTAssertEqual(result.amount, 4000)
    }

    func test_calculate_threeHoursExact_returns6000() {
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_010_800)

        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut, remoteConfig: nil)

        XCTAssertEqual(result, TariffResult(duration: 10800, hours: 3, amount: 6000))
    }

    func test_calculate_zeroDuration_returnsZero() {
        let time = Date(timeIntervalSince1970: 1_000_000)

        let result = TariffCalculator.calculate(checkIn: time, checkOut: time, remoteConfig: nil)

        XCTAssertEqual(result, TariffResult(duration: 0, hours: 0, amount: 0))
    }

    func test_calculate_lessThanOneHour_roundsUpToOne() {
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_001_800)

        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut, remoteConfig: nil)

        XCTAssertEqual(result.hours, 1)
        XCTAssertEqual(result.amount, 2000)
    }

    func test_calculate_withRCTariff_usesRCValue() {
        let rc = MockRC(tariff: 3000)
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_003_600)

        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut, remoteConfig: rc)

        XCTAssertEqual(result.amount, 3000)
    }

    func test_calculate_withRCZero_fallsBackToDefault() {
        let rc = MockRC(tariff: 0)
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_003_600)

        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut, remoteConfig: rc)

        XCTAssertEqual(result.amount, 2000)
    }
}

private final class MockRC: RemoteConfigServiceProtocol {
    private let tariff: Int
    init(tariff: Int) { self.tariff = tariff }
    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void) { completion(.success(())) }
    func int(forKey key: String) -> Int { tariff }
}
