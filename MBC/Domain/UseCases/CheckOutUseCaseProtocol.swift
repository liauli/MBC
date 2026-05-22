import Foundation

protocol CheckOutUseCaseProtocol {
    func execute() async throws -> (MemberCard, TariffResult)
}
