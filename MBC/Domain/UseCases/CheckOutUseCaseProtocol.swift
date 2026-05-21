import Foundation

protocol CheckOutUseCaseProtocol {
    func execute(completion: @escaping (Result<(MemberCard, TariffResult), MBCError>) -> Void)
}
