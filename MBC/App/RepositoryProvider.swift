import Foundation

final class RepositoryProvider {
    static let instance = RepositoryProvider()

    private let serviceProvider = ServiceProvider.instance

    func provideCardRepository() -> CardRepositoryProtocol {
        CardRepository(
            nfcService: serviceProvider.provideNFCService(),
            cryptoService: serviceProvider.provideCryptoService(),
            serializer: serviceProvider.provideCardSerializer()
        )
    }

    func providePINRepository() -> PINRepositoryProtocol {
        PINRepository(keychain: serviceProvider.provideKeychainWrapper())
    }
}
