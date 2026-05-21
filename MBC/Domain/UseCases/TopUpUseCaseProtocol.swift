import Foundation

protocol TopUpUseCaseProtocol {
    func execute(amount: Int, completion: @escaping (Result<MemberCard, MBCError>) -> Void)
}
