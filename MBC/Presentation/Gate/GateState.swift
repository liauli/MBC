import Foundation

enum GateState: Equatable {
    case idle
    case scanning
    case success(MemberCard)
    case error(String)
}
