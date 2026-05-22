import Foundation

protocol NFCServiceProtocol {
    func read() async throws -> Data
    func write(_ data: Data) async throws
}
