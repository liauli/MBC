import Foundation

final class ServiceProvider {
    static let instance = ServiceProvider()

    private lazy var nfcService: NFCServiceProtocol = NFCService()
    private lazy var cryptoService: CryptoServiceProtocol = CryptoService()
    private lazy var cardSerializer: CardSerializerProtocol = CardSerializer()
    private lazy var keychainWrapper: KeychainWrapperProtocol = KeychainWrapper()

    func provideNFCService() -> NFCServiceProtocol {
        nfcService
    }

    func provideCryptoService() -> CryptoServiceProtocol {
        cryptoService
    }

    func provideCardSerializer() -> CardSerializerProtocol {
        cardSerializer
    }

    func provideKeychainWrapper() -> KeychainWrapperProtocol {
        keychainWrapper
    }
}
