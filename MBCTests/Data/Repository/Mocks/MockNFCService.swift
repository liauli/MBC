import Foundation
@testable import MBC

final class MockNFCService: NFCServiceProtocol {
    var readResult: Result<Data, MBCError> = .failure(.nfcReadFailed)
    var writeResult: Result<Void, MBCError> = .success(())
    var writtenData: Data?
    var readCallCount = 0
    var writeCallCount = 0

    func read() async throws -> Data {
        readCallCount += 1
        switch readResult {
        case let .success(data): return data
        case let .failure(error): throw error
        }
    }

    func write(_ data: Data) async throws {
        writeCallCount += 1
        writtenData = data
        switch writeResult {
        case .success: return
        case let .failure(error): throw error
        }
    }

    func readAndWrite(_ transform: @escaping (Data) throws -> Data) async throws -> Data {
        readCallCount += 1
        switch readResult {
        case let .success(data):
            let output = try transform(data)
            writeCallCount += 1
            writtenData = output
            switch writeResult {
            case .success: return output
            case let .failure(error): throw error
            }
        case let .failure(error):
            throw error
        }
    }
}
