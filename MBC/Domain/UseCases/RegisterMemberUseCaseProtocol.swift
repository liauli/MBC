import Foundation

protocol RegisterMemberUseCaseProtocol {
    func execute(name: String, completion: @escaping (Result<MemberCard, MBCError>) -> Void)
}
