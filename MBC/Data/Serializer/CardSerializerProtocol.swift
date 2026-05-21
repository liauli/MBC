import Foundation

protocol CardSerializerProtocol {
    func serialize(_ card: MemberCard) throws -> Data
    func deserialize(_ data: Data) throws -> MemberCard
}
