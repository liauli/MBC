import Foundation

protocol KeychainWrapperProtocol {
    func save(_ data: Data, for key: String) -> Bool
    func read(for key: String) -> Data?
    func delete(for key: String) -> Bool
}
