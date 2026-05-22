import FirebaseRemoteConfig
import Foundation

protocol RemoteConfigServiceProtocol {
    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void)
    func int(forKey key: String) -> Int
}

final class RemoteConfigService: RemoteConfigServiceProtocol {
    private let remoteConfig: RemoteConfig

    init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3600
        #endif
        remoteConfig.configSettings = settings
    }

    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void) {
        remoteConfig.fetchAndActivate { _, error in
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func int(forKey key: String) -> Int {
        remoteConfig.configValue(forKey: key).numberValue.intValue
    }
}
