import Foundation

protocol RegisterMemberUseCaseProtocol {
    func execute(name: String) async throws -> MemberCard
}
