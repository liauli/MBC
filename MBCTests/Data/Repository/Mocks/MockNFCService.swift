import Foundation
@testable import MBC

final class MockNFCService: NFCServiceProtocol {
    var readResult: Result<Data, MBCError> = .failure(.nfcReadFailed)
    var writeResult: Result<Void, MBCError> = .success(())
    var writtenData: Data?
    var readCallCount = 0
    var writeCallCount = 0

    func read(completion: @escaping (Result<Data, MBCError>) -> Void) {
        readCallCount += 1
        completion(readResult)
    }

    func write(_ data: Data, completion: @escaping (Result<Void, MBCError>) -> Void) {
        writeCallCount += 1
        writtenData = data
        completion(writeResult)
    }
}
