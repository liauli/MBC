import Foundation

protocol CheckInUseCaseProtocol {
    func execute(simulatedTime: Date?) async throws -> MemberCard
}
