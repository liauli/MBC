import Foundation

protocol ReadCardUseCaseProtocol {
    func execute() async throws -> MemberCard
}
