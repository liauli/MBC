import Foundation

enum TariffCalculator {
    private static let defaultRate = 2000

    static func calculate(checkIn: Date, checkOut: Date, remoteConfig: RemoteConfigServiceProtocol?) -> TariffResult {
        let rate = tariffRate(from: remoteConfig)
        let duration = checkOut.timeIntervalSince(checkIn)
        let seconds = max(0, Int(duration))
        let hours = ceilingHours(seconds: seconds)
        let amount = hours * rate
        return TariffResult(duration: duration, hours: hours, amount: amount)
    }

    private static func tariffRate(from remoteConfig: RemoteConfigServiceProtocol?) -> Int {
        let value = remoteConfig?.int(forKey: "memberTariff") ?? 0
        return value > 0 ? value : defaultRate
    }

    private static func ceilingHours(seconds: Int) -> Int {
        guard seconds > 0 else { return 0 }
        return (seconds + 3599) / 3600
    }
}
