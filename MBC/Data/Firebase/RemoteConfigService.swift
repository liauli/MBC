import FirebaseRemoteConfig
import Foundation

protocol RemoteConfigServiceProtocol {
    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void)
    func bool(forKey key: String) -> Bool
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

    func bool(forKey key: String) -> Bool {
        remoteConfig.configValue(forKey: key).boolValue
    }
}
