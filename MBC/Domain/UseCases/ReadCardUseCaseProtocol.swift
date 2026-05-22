import Foundation

protocol ReadCardUseCaseProtocol {
    func execute(completion: @escaping (Result<MemberCard, MBCError>) -> Void)
}
