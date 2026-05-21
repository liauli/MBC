import Foundation

protocol CheckInUseCaseProtocol {
    func execute(
        simulatedTime: Date?,
        completion: @escaping (Result<MemberCard, MBCError>) -> Void
    )
}
