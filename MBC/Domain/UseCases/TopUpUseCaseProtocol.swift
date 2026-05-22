import Foundation

protocol TopUpUseCaseProtocol {
    func execute(amount: Int) async throws -> MemberCard
}
