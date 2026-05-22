import Foundation

protocol CardRepositoryProtocol {
    func readCard() async throws -> MemberCard
    func writeCard(_ card: MemberCard) async throws
    func readAndUpdateCard(_ update: @escaping (MemberCard) throws -> MemberCard) async throws -> MemberCard
}
