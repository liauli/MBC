@testable import MBC
import XCTest

final class TariffCalculatorTests: XCTestCase {
    func test_calculate_exactOneHour_returns2000() {
        // Given
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_003_600)

        // When
        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut)

        // Then
        XCTAssertEqual(result, TariffResult(duration: 3600, hours: 1, amount: 2000))
    }

    func test_calculate_oneSecondOverHour_roundsUp() {
        // Given
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_003_601)

        // When
        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut)

        // Then
        XCTAssertEqual(result.hours, 2)
        XCTAssertEqual(result.amount, 4000)
    }

    func test_calculate_threeHoursExact_returns6000() {
        // Given
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_010_800)

        // When
        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut)

        // Then
        XCTAssertEqual(result, TariffResult(duration: 10800, hours: 3, amount: 6000))
    }

    func test_calculate_zeroDuration_returnsZero() {
        // Given
        let time = Date(timeIntervalSince1970: 1_000_000)

        // When
        let result = TariffCalculator.calculate(checkIn: time, checkOut: time)

        // Then
        XCTAssertEqual(result, TariffResult(duration: 0, hours: 0, amount: 0))
    }

    func test_calculate_lessThanOneHour_roundsUpToOne() {
        // Given
        let checkIn = Date(timeIntervalSince1970: 1_000_000)
        let checkOut = Date(timeIntervalSince1970: 1_001_800)

        // When
        let result = TariffCalculator.calculate(checkIn: checkIn, checkOut: checkOut)

        // Then
        XCTAssertEqual(result.hours, 1)
        XCTAssertEqual(result.amount, 2000)
    }
}
