import Foundation

enum TerminalState: Equatable {
    case idle
    case scanning
    case success(MemberCard, TariffResult)
    case error(String)
}
