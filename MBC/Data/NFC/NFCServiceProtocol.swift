import Foundation

protocol NFCServiceProtocol {
    func read(completion: @escaping (Result<Data, MBCError>) -> Void)
    func write(_ data: Data, completion: @escaping (Result<Void, MBCError>) -> Void)
}
