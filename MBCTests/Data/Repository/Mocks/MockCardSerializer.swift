import Foundation
@testable import MBC

final class MockCardSerializer: CardSerializerProtocol {
    var serializeResult: Result<Data, Error> = .success(Data())
    var deserializeResult: Result<MemberCard, Error> = .failure(MBCError.deserializationFailed)
    var serializeCallCount = 0
    var deserializeCallCount = 0

    func serialize(_ card: MemberCard) throws -> Data {
        serializeCallCount += 1
        switch serializeResult {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }

    func deserialize(_ data: Data) throws -> MemberCard {
        deserializeCallCount += 1
        switch deserializeResult {
        case let .success(result): return result
        case let .failure(error): throw error
        }
    }
}
