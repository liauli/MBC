import Foundation

protocol CardRepositoryProtocol {
    func readCard(completion: @escaping (Result<MemberCard, MBCError>) -> Void)
    func writeCard(_ card: MemberCard, completion: @escaping (Result<Void, MBCError>) -> Void)
    func readAndUpdateCard(
        _ update: @escaping (MemberCard) throws -> MemberCard,
        completion: @escaping (Result<MemberCard, MBCError>) -> Void
    )
}
