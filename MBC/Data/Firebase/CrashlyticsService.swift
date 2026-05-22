import FirebaseCrashlytics
import Foundation

protocol CrashlyticsServiceProtocol {
    func logNonFatal(_ error: Error)
    func log(_ message: String)
    func setUserID(_ id: String)
}

final class CrashlyticsService: CrashlyticsServiceProtocol {
    private let crashlytics: Crashlytics

    init() {
        crashlytics = Crashlytics.crashlytics()
    }

    func logNonFatal(_ error: Error) {
        crashlytics.record(error: error)
    }

    func log(_ message: String) {
        crashlytics.log(message)
    }

    func setUserID(_ id: String) {
        crashlytics.setUserID(id)
    }
}
