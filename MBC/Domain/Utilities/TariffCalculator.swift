import Foundation

enum TariffCalculator {
    private static let ratePerHour = 2000

    static func calculate(checkIn: Date, checkOut: Date) -> TariffResult {
        let duration = checkOut.timeIntervalSince(checkIn)
        let seconds = max(0, Int(duration))
        let hours = ceilingHours(seconds: seconds)
        let amount = hours * ratePerHour
        return TariffResult(duration: duration, hours: hours, amount: amount)
    }

    private static func ceilingHours(seconds: Int) -> Int {
        guard seconds > 0 else { return 0 }
        return (seconds + 3599) / 3600
    }
}
